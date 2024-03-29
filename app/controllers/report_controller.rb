# frozen_string_literal: true

# Controller for report
class ReportController < ApplicationController
  DEF_PARAMS_START_DATE = '2015-07-01'.freeze
  DEF_PARAMS_END_DATE = '2021-12-12'.freeze
  USERS_IN_BATCH = 30
  SESSIONS_PER_USER = 1_000
  BATCH_SIZE = 30_000

  around_action :profile_with_stackprof_json, only: :report, if: -> { params[:profile] == 'json' }
  around_action :profile_with_stackprof_raw, only: :report, if: -> { params[:profile] == 'raw' }
  around_action :wrap_in_mem_prof, only: :report, if: -> { params[:profile] == 'measure_mem' }
  around_action :profile_with_ruby_prof, only: :report, if: -> { params[:profile] == 'ruby_prof' }
  before_action :accept_all_params

  def report
    @start_date = Date.parse(params.fetch(:start_date, DEF_PARAMS_START_DATE))
    @finish_date = Date.parse(params.fetch(:finish_date, DEF_PARAMS_END_DATE))

    sessions = Session.where(
      'date >= :start_date AND date <= :finish_date',
      start_date: @start_date,
      finish_date: @finish_date
    )
    .order(:user_id, :id)
    .preload(:user)

    work(sessions)
  end

  private

  def accept_all_params
    params.permit!
  end

  # :reek:DuplicateMethodCall :reek:NilCheck
  def work(sessions)
    @users = []
    batch_number = 0; @total_users = 0; @total_sessions = 0
    browsers_set = Set.new

    prev_user = nil
    user_sessions = []

    while true do
      batch = load_batch_of_sessions(sessions, batch_number: batch_number, size: BATCH_SIZE)
      batch_number += 1
      batch.each do |session|
        user = session.user
        # TODO: uncomment, but we need to seed more users/sessions, gem valid_email2 alr. configured
        # next unless user.valid?
        if prev_user.nil?
          prev_user = user
          @total_users += 1
        elsif user.id != prev_user&.id # Found next user
          @total_users += 1
          stats_for_user(prev_user, user_sessions) if prev_user
          prev_user = user
          user_sessions = []
          break if total_users_in_batch?
        end
        user_sessions << session
        browsers_set << session.browser
        @total_sessions += 1
      end
      last_session_flag = Session.last&.id == user_sessions.last&.id
      user_sessions.present? and last_session_flag and stats_for_user(prev_user, user_sessions)
      break if total_users_in_batch? || last_session_flag
    end

    @unique_browsers_count = browsers_set.size
  end

  ##
  ## auxiliary variables for #work
  ##
  def load_batch_of_sessions(sessions, batch_number:, size: SESSIONS_PER_USER)
    sessions.limit(size).offset(batch_number * size)
  end

  def stats_for_user(user, user_sessions)
    @users << {}.merge(form_user_stats(user)).merge(form_user_sessions_stats(user_sessions))
  end

  def form_user_stats(user)
    {
      first_name: user.first_name,
      last_name: user.last_name
    }
  end

  # :reek:FeatureEnvy
  def form_user_sessions_stats(user_sessions)
    duration_of_sessions = user_sessions.map(&:duration)
    browsers_list = user_sessions.map(&:browser).map(&:upcase)
    {
      sessions_count: user_sessions.count,
      total_time: "#{duration_of_sessions.sum} min.",
      longest_session: "#{duration_of_sessions.max} min.",
      browsers: form_stats_browsers_part(browsers_list),
      used_ie: form_stats_browsers_part(browsers_list, used: 'ie'),
      used_only_chrome: form_stats_browsers_part(browsers_list, used: 'chrome'),
      dates: user_sessions.map(&:date).map(&:to_s).sort.uniq
    }
  end

  # :reek:ControlParameter
  def form_stats_browsers_part(browsers_list, used: nil)
    return browsers_list.sort.uniq unless used

    case used
    when 'chrome'
      browsers_list.all? { |browser| browser =~ /CHOME/ }
    when 'ie'
      browsers_list.any? { |browser| browser =~ /INTERNET EXPLORER/ }
    end
  end

  def total_users_in_batch?
    @total_users > USERS_IN_BATCH
  end
end
