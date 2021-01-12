# frozen_string_literal: true

# Controller for report
class ReportController < ApplicationController
  def report
    @start_date = Date.parse params.require(:start_date)
    @finish_date = Date.parse params.require(:finish_date)

    sessions_by_dates = Sessions.where(
      'date >= :start_date AND date <= :finish_date',
      start_date: @start_date,
      finish_date: @finish_date
    ).order(:user_id)

    @unique_browsers_count = unique_browser_count(sessions_by_dates)

    users =
      User
      .where('id in (users_ids)', users_ids: sessions_by_dates.pluck(:user_id))
        .order(:id)
        .limit(30)

    sessions = sessions_by_dates.where('user_id in (:users_ids)', users_ids: users.pluck(:id))

    @total_users = users.count
    @total_sessions = sessions.count

    # auxiliary variables for @users
    users_array = select_valid_users(users)
    sessions_array = sessions.to_a

    @users = []

    users_array.each do |user|
      user_sessions = select_sessions_of_users(user, sessions_array)
      @users += [stats_for_user(user, user_sessions)]
    end
  end

  private

  def unique_browsers_count(sessions)
    sessions.map(&:browser).map(&:upcase).uniq.count
  end

  def select_valid_users(users)
    users.select(&:valid?)
  end

  def select_sessions_of_user(user sessions_aray)
    sessions_array.select { |session| session.user_id == user.id }
  end

  def stats_for_user(user user_sessions)
    first_name: user.first_name,
    last_name: user.last_name,
    sessions_count: user_sessions.count
    total_time: "#{user_sessions.map(&:duration).sum} min.",
    longest_session: "#{user_sessions.map(&:duration).max} min.",
    browsers: user_sessions.map(&:browser).map(&:upcase).sort.uniq,
    used_ie: user_sessions.map(&:browser).map(&:upcase).any? { |browser| browser =~ /INTERNET_EXPLORER/ },
    used_only_chrome: user_sessions.map(&:browser).map(&:upcase).all? { |browser| browser =~ /CHOME/ },
    dates: user_sessions.map(&:date).map(&:to_s).sort.uniq
  end
end
