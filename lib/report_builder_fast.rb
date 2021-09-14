# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

class ReportBuilderFast
  # +filename+ or env DATA_FILE
  # +report_filename+
  # +disable_gc+ - disable garbage collector
  # def call(..., disable_gc: true); end
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
    uniqueBrowsers = []; sessions_real = []
    sessions.each do |session|
      sessions_real << Session.new(**session.except(:id))
      brows = session[:browser]
      uniqueBrowsers << brows if uniqueBrowsers.all? { |b| b != brows }
    end

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] = uniqueBrowsers.sort.uniq.join(',') # here uniq is useless

    # Статистика по пользователям
    users_objects = []
    report['usersStats'] = {}

    users.each do |user|
      attributes = user
      # user_sessions = Session.where(user_id: user[:id])
      user_sessions = sessions_real.select { |ses| ses.serializable_hash.fetch("user_id") == user[:id].to_i }

      user_object = User.new(user_attribs: { **attributes }, sessions: user_sessions)
      user_object.save
      users_objects = users_objects + [user_object]
    end

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount': user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime': user.sessions.collect(&:duration).map { |t| t.to_i }.sum.to_s + ' min.' }
      # { 'totalTime': Session.where(user_id: user[:id]).pluck(:duration).map { |t| t.to_i }.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession': user.sessions.collect(&:duration).map { |t| t.to_i }.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers': user.sessions.collect(&:browser).map { |b| b.upcase }.sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE': user.sessions.collect(&:browser).any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome': user.sessions.collect(&:browser).all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601 # Change sort to: order(date: :desc).pluck(:date)
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates': user.sessions.pluck(:date).sort.reverse.map { |d| d.iso8601 } }
    end

    File.write("payloads/#{report_filename}", "#{report.to_json}\n")
    puts 'Finish work'
  end

  private

  def collect_stats_from_users(report, users_objects, &block)
    users_objects.each do |user|
      user_key = "#{user.first_name}" + ' ' + "#{user.last_name}"

      report['usersStats'][user_key] ||= {}
      report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
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

  # Don't parse id of session!
  def parse_session(session)
    cols = session.split(',')
    parsed_result = {
      'user_id': cols[1],
      'id': cols[2],
      'browser': cols[3].upcase,
      'duration': cols[4],
      'date': cols[5],
    }
  end
end
