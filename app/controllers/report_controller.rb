# frozen_string_literal: true

# Controller for report
class ReportController < ApplicationController
  LOGGER_BAR = ('*' * 40).freeze
  DEF_PARAMS_START_DATE = '2015-07-01'.freeze
  DEF_PARAMS_END_DATE = '2021-12-12'.freeze

  around_action :profile_with_stackprof, only: :report, if: -> { params[:profile] == 'json' }
  around_action :wrap_in_mem_prof, only: :report, if: -> { params[:profile] == 'measure_mem' }
  around_action :profile_with_ruby_prof, only: :report, if: -> { params[:profile] == 'ruby_prof' }
  before_action :accept_all_params

  def report
    @start_date = Date.parse(params.fetch(:start_date, DEF_PARAMS_START_DATE))
    @finish_date = Date.parse(params.fetch(:finish_date, DEF_PARAMS_END_DATE))

=begin TODO: Refactor app in stream-style
  In certain moment all 90MB of sessions DB table can be loader to memory
    (with AR wrapping it's more). So let's implement records loading in batches.
  An algorithm will extract all needed data from an batch,
    data will be keept batch will be replaced with next batch.
=end
    sessions_by_dates = Session.where(
      'date >= :start_date AND date <= :finish_date',
      start_date: @start_date,
      finish_date: @finish_date
    ).order(:user_id)

    # @unique_browsers_count = unique_browsers_count(sessions_by_dates)

    sl = sessions_by_dates.pluck(:user_id).uniq
    users =
      User
      .where(id: sl)
        .order(:id)
        .limit(30)

    sessions = sessions_by_dates.where(user_id: sl)
    @unique_browsers_count = unique_browsers_count(sessions)

    @total_users = users.count
    @total_sessions = sessions.count

    # users_array = select_valid_users(users) # TODO: now it is safe to add it (but seed more users/sessions)
    @users = []

    load_users(users).each do |user|
      user_sessions = select_sessions_of_user(user, load_sessions(sessions))
      @users += [stats_for_user(user, user_sessions)]
    end
  end

  private

  # We will use visualization in a browser in flame-graph format https://speedscope.app
  def profile_with_stackprof(&block)
    # return block.call if params[:profile] != 'json'
    profile = StackProf.run(mode: :wall, raw: true, &block)
    File.write('tmp/stackprof.json', JSON.generate(profile))
  end

  # Legent: rss - Resident Set Size
  # Amount of RAM in MB, assigned to process
  def mem_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1_024
  end

  def log_memory_usage(mem)
    Rails.logger.info(LOGGER_BAR + "\n" + "#{mem} MB".rjust(96) + "\n" + LOGGER_BAR.rjust(129))
  end

  def wrap_in_mem_prof
    GC.start(full_mark: true, immediate_sweep: true)
    GC.disable
    mem_before = mem_usage

    yield

    mem_after = mem_usage
    log_memory_usage(mem_after - mem_before)
  end

  def profile_with_ruby_prof
    RubyProf.measure_mode = RubyProf::MEMORY
    profile = RubyProf.profile { yield }
    printer = RubyProf::CallTreePrinter.new(profile)
    printer.print(path: 'tmp', profile: 'rubyprof')
  end

  def accept_all_params
    params.permit!
  end

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
    @sessions_of_user ||= sessions_array.group_by(&:user_id)
    @sessions_of_user[user.id]
  end

  # :reek:FeatureEnvy
  def stats_for_user(user, user_sessions)
    duration_of_sessions = user_sessions.map(&:duration)
    { first_name: user.first_name,
      last_name: user.last_name,
      sessions_count: user_sessions.count,
      total_time: "#{duration_of_sessions.sum} min.",
      longest_session: "#{duration_of_sessions.max} min.",
      browsers: stats_browsers_part(user_sessions),
      used_ie: stats_browsers_part(user_sessions, used: 'ie'),
      used_only_chrome: stats_browsers_part(user_sessions, used: 'chrome'),
      dates: user_sessions.map(&:date).map(&:to_s).sort.uniq
    }
  end

  def stats_browsers_part(user_sessions, used: 'all')
    get_browsers_list = user_sessions.map(&:browser).map(&:upcase)
    case used
    when 'chrome'
      get_browsers_list.all? { |browser| browser =~ /CHOME/ }
    when 'ie'
      get_browsers_list.any? { |browser| browser =~ /INTERNET_EXPLORER/ }
    else
      get_browsers_list.sort.uniq
    end
  end
end
