# frozen_string_literal: true

# Controller for report
class ReportController < ApplicationController
  DEF_PARAMS_START_DATE = '2015-07-01'.freeze
  DEF_PARAMS_END_DATE = '2021-12-12'.freeze

  around_action :profile_with_stackprof, only: :report, if: -> { params[:profile] == 'json' }
  around_action :wrap_in_mem_prof, only: :report, if: -> { params[:profile] == 'measure_mem' }
  around_action :profile_with_ruby_prof, only: :report, if: -> { params[:profile] == 'ruby_prof' }
  before_action :accept_all_params

  def report
    @start_date = Date.parse(params.fetch(:start_date, DEF_PARAMS_START_DATE))
    @finish_date = Date.parse(params.fetch(:finish_date, DEF_PARAMS_END_DATE))

    sessions_by_dates = Session.where(
      'date >= :start_date AND date <= :finish_date',
      start_date: @start_date,
      finish_date: @finish_date
    ).order(:user_id)

    # @unique_browsers_count = unique_browsers_count(sessions_by_dates)

    load_sessions_ids = sessions_by_dates.pluck(:user_id).uniq

    users =
      User
      .where(id: load_sessions_ids)
        .order(:id)
        .limit(30)

    sessions = sessions_by_dates.where(user_id: load_sessions_ids)

    @unique_browsers_count = unique_browsers_count(sessions)
    @total_users = users.count
    @total_sessions = sessions.count
    work(users, sessions)
  end

  private

  def accept_all_params
    params.permit!
  end

  def unique_browsers_count(sessions)
    sessions.map(&:browser).uniq.count
    # sessions.select(&:browser).distinct.count
  end

  def work(users, sessions)
    @users = []

    load_valid_users(users).each do |user|
      user_sessions = select_sessions_of_user(user, load_sessions(sessions))
      @users += [stats_for_user(user, user_sessions)]
    end
  end

  ##
  ## auxiliary variables for #work
  ##
  def select_valid_users(users)
    users.select(&:valid?)
  end

  def load_users(users)
    users.to_a
  end

  # TODO: we need to seed more users/sessions, gem valid_email2 alr. configured
  def load_valid_users(users)
    select_valid_users(users)
  end

  def load_sessions(sessions)
    sessions.to_a
  end

  def load_batch_of_sessions(sessions, batch_number:, size: 1_000)
    sessions.limit(size).offset(batch_number * size)
  end

  def select_sessions_of_user(user, sessions_array)
    # sessions_array.select { |session| session.user_id == user.id }
    @sessions_of_user ||= sessions_array.group_by(&:user_id)
    @sessions_of_user[user.id]
  end

  # :reek:FeatureEnvy
  def stats_for_user(user, user_sessions)
    duration_of_sessions = user_sessions.map(&:duration)
    browsers_list = user_sessions.map(&:browser).map(&:upcase)
    { first_name: user.first_name,
      last_name: user.last_name,
      sessions_count: user_sessions.count,
      total_time: "#{duration_of_sessions.sum} min.",
      longest_session: "#{duration_of_sessions.max} min.",
      browsers: stats_browsers_part(browsers_list),
      used_ie: stats_browsers_part(browsers_list, used: 'ie'),
      used_only_chrome: stats_browsers_part(browsers_list, used: 'chrome'),
      dates: user_sessions.map(&:date).map(&:to_s).sort.uniq
    }
  end

  def stats_browsers_part(browsers_list, used: 'all')
    case used
    when 'chrome'
      browsers_list.all? { |browser| browser =~ /CHOME/ }
    when 'ie'
      browsers_list.any? { |browser| browser =~ /INTERNET EXPLORER/ }
    else
      browsers_list.sort.uniq
    end
  end
end
