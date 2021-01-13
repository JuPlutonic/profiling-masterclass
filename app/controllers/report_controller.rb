# frozen_string_literal: true

# Controller for report
class ReportController < ApplicationController
  # around_action :profile_with_stackprof, only: :report

  # def profile_with_stackprof(&block)
  #   if params[:profile] == 'json'
  #     profile = StackProf.run(mode: :wall, raw: true, &block)
  #     File.write('tmp/stackprof.json', JSON.generate(profile))
  #   else
  #     block.call
  #   end
  # end

  def report
    @start_date = Date.parse params.require(:start_date)
    @finish_date = Date.parse params.require(:finish_date)

    sessions_by_dates = Session.where(
      'date >= :start_date AND date <= :finish_date',
      start_date: @start_date,
      finish_date: @finish_date
    ).order(:user_id)

    # @unique_browsers_count = unique_browsers_count(sessions_by_dates)

    users =
      User
        .where('id in (:users_ids)', users_ids: sessions_by_dates.pluck(:user_id))
        .order(:id)
        .limit(30)

    sessions = sessions_by_dates.where('user_id in (:users_ids)', users_ids: users.pluck(:id))
    @unique_browsers_count = unique_browsers_count(sessions)

    @total_users = users.count
    @total_sessions = sessions.count

    # users_array = select_valid_users(users)
    # sessions_array = sessions.to_a
    @users = []

    # users_array.each do |user|
    load_users(users).each do |user|
      # user_sessions = select_sessions_of_user(user, sessions_array)
      user_sessions = select_sessions_of_user(user, load_sessions(sessions))
      @users += [stats_for_user(user, user_sessions)]
    end
  end

  private

  def unique_browsers_count(sessions)
    sessions.map(&:browser).map(&:upcase).uniq.count
    # sessions.select(&:browser).distinct.count
  end

  ##
  ## auxiliary variables for @users
  ##
  def select_valid_users(users)
    users.select(&:valid?)
  end

  def load_users(users)
    # users.to_a
    select_valid_users(users)
  end

  def load_sessions(sessions)
    sessions.to_a
  end

  # def load_batch_of_sessions(sessions, batch_number:, size: 1_000)
  #   sessions.limit(size).offset(batch_number * size)
  # end
  ##
  ##
  ##

  def select_sessions_of_user(user, sessions_array)
    # sessions_array.select { |session| session.user_id == user.id }
    @sessions_of_user ||= sessions_array.group_by(user_id)
    @sessions_of_user[user.id]
  end

  def stats_for_user(user, user_sessions)
    { first_name: user.first_name,
      last_name: user.last_name,
      sessions_count: user_sessions.count,
      total_time: "#{user_sessions.map(&:duration).sum} min.",
      longest_session: "#{user_sessions.map(&:duration).max} min.",
      browsers: user_sessions.map(&:browser).map(&:upcase).sort.uniq,
      used_ie: user_sessions.map(&:browser).map(&:upcase).any? { |browser| browser =~ /INTERNET_EXPLORER/ },
      used_only_chrome: user_sessions.map(&:browser).map(&:upcase).all? { |browser| browser =~ /CHOME/ },
      dates: user_sessions.map(&:date).map(&:to_s).sort.uniq
    }
  end
end
