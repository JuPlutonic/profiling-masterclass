# frozen_string_literal: true

require 'json'
# require 'date'

# db_file_io builds report (reads/parses from TXT file information and forms JSON report, creates users/sessions in DB)
class ReportBuilder
  MEMORY_LIMIT_MB = 70

  #
  # +filename+ or env DATA_FILE
  # +disable_gc+ - disable garbage collector

  # def call(filename = 'payloads/data.txt', disable_gc: true)
  # def call(filename = 'payloads/data_6000.txt')
  def call(filename = 'payloads/data.txt')
    puts 'Start work'
    # GC.disable if disable_gc
    file_lines = File.read(ENV['DATA_FILE'] || filename).split("\n")

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

    report = {}

    report[:totalUsers] = users.count

    # Подсчёт количества уникальных браузеров
    uniqueBrowsers = []
    sessions.each do |session|
      browser = session[:browser]
      uniqueBrowsers << [browser] if uniqueBrowsers.all? { |b| b != browser }
    end

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] = uniqueBrowsers.sort

    # Статистика по пользователям
    users_objects = []

    users.each do |user|
      attributes = user
      user_sessions = select_session_for_user(sessions, user)
      # binding.pry
      user_object = User.new(attributes: { **attributes }, sessions: user_sessions)
      users_objects = users_objects + [user_object]
    end

    report['usersStats'] = {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount': user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime': user.sessions.map { |s| s['time'] }.map { |t| t.to_i }.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession': user.sessions.map { |s| s['time'] }.map { |t| t.to_i }.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      st = { 'browsers': user.sessions.map { |s| s['browser'] }.map { |b| b.upcase }.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE': user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome': user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates': user.sessions.map { |s| s['date'] }.map { |d| Date.parse(d) }.sort.reverse.map { |d| d.iso8601 } }
    end

    File.write('payloads/result_small.json', "#{report.to_json}\n")
    puts 'Finish work'
  end

  private

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
    end
  end

  def select_session_for_user(sessions, user)
    sessions.select { |session| session['user_id'] == user['id'] }
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
    fields = user.split(',')
    parsed_result = {
      'id': fields[1],
      'first_name': fields[2],
      'last_name': fields[3],
      'age': fields[4],
    }
  end

  def parse_session(session)
    fields = session.split(',')
    parsed_result = {
      'user_id': fields[1],
      'session_id': fields[2],
      'browser': fields[3],
      'time': fields[4],
      'date': fields[5],
    }
  end

  # def memory_usage_metric
  #   ram_used = `ps -o rss= -p #{Process.pid}`.to_i / 1_024 # 1_024 for megabytes
  #   puts "❌ MEMORY USAGE IS #{ram_used} MB" if ram_used > MEMORY_LIMIT_MB
  # end
end
