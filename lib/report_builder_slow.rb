# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

class ReportBuilderSlow
  # +filename+ or env DATA_FILE
  # +report_filename+
  # +disable_gc+ - disable garbage collector
  # def call(..., disable_gc: false); end
  def call(filename = 'data_18.txt', report_filename)
    puts 'Start work'
    # GC.disable if disable_gc
    file_lines = File.read("payloads/#{ENV['DATA_FILE'] || filename}").split("\n")

    users, sessions = parse_file_lines(file_lines)

    # Отчёт в json
    #   - Сколько всего юзеров +
    #   - Сколько всего уникальных браузеров +
    #   - Сколько всего сессий +
    #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
    #
    #   - По каждому пользователю
    #     - сколько всего сессий +
    #     - сколько всего времени +
    #     - самая длинная сессия +
    #     - браузеры через запятую +
    #     - Хоть раз использовал IE? +
    #     - Всегда использовал только Хром? +
    #     - даты сессий в порядке убывания через запятую +

    report = ActiveSupport::HashWithIndifferentAccess.new

    report[:totalUsers] = users.count

    # Подсчёт количества уникальных браузеров
    uniqueBrowsers = []
    sessions.each do |session|
      browser = session[:browser]
      uniqueBrowsers << [browser] if uniqueBrowsers.all? { |b| b != [browser] }
    end

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] = uniqueBrowsers.sort.uniq.join(',')

    # Статистика по пользователям
    users_objects = []
    report['usersStats'] = {}

    users.each do |user|
      attributes = user
      user_sessions = select_session_for_user(sessions, user)
      # user_object = User.new(attributes: { **attributes }, sessions: user_sessions)
      user_object = User.new(user_attribs: { **attributes }, sessions: user_sessions)
      users_objects = users_objects + [user_object]
    end

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount': user.attributes[:sessions].count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime': user.attributes[:sessions].collect { |s| s[:time] }.map { |t| t.to_i }.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession': user.attributes[:sessions].collect { |s| s[:time] }.map { |t| t.to_i }.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers': user.attributes[:sessions].collect { |s| s[:browser] }.map { |b| b.upcase }.sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE': user.attributes[:sessions].collect { |s| s[:browser] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome': user.attributes[:sessions].collect { |s| s[:browser] }.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates': user.attributes[:sessions].collect { |s| s[:date] }.map { |d| Date.parse(d) }.sort.reverse.map { |d| d.iso8601 } }
    end

    File.write("payloads/#{report_filename}", "#{report.to_json}\n")
    puts 'Finish work'
  end

  private

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.attributes[:user_attribs][:first_name]}" + ' ' + "#{user.attributes[:user_attribs][:last_name]}"

      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
    end
  end

  def select_session_for_user(sessions, user)
    sessions.select { |session| session[:user_id] == user[:id] }
    # sessions.select { |session| session[:user_id] == user[:id] }.each { |x| x[:id] = x.delete(:session_id) }.each { |x| x[:duration] = x.delete(:time) }.each_with_object([]) { |el, o_ary| o_ary << Session.new(el) }
  end

  def parse_file_lines(lines)
    users = []
    sessions = []

    lines.each do |line|
      cols = line.split(',')
      users = users + [parse_user(line)] if cols[0] == 'user'
      sessions = sessions + [parse_session(line)] if cols[0] == 'session'
    end

    [users, sessions]
  end

  def parse_user(user)
    cols = user.split(',')
    parsed_result = {
      'id': cols[1],
      'first_name': cols[2],
      'last_name': cols[3],
      'age': cols[4],
    }
  end

  def parse_session(session)
    cols = session.split(',')
    parsed_result = {
      'user_id': cols[1],
      'session_id': cols[2],
      'browser': cols[3].upcase,
      'time': cols[4],
      'date': cols[5],
    }
  end
end
