# Тут находится программа, выполняющая обработку данных из файла.
# Тест показывает как программа должна работать.
# В этой программе нужно обработать файл данных data_large.txt.

# Ожидания от результата:

# Корректная обработатка файла data_large.txt;
# Проведена оптимизация кода и представлены ее результаты;
# Production-ready код;
# Применены лучшие практики;

require 'json'
require 'date'
require_relative 'user'
require_relative 'session'

module BrowserDataParser
  class ParseFile
    def call(input_file_path:, output_file_path:)
      file_lines = File.read(input_file_path).split("\n")

      users = []
      sessions = []

      file_lines.each do |line|
        cols = line.split(',')
        users.push(User.new(line)) if cols[0] == 'user'
        sessions.push(Session.new(line)) if cols[0] == 'session'
      end

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
      uniqueBrowsers = sessions.map(&:browser).uniq

      report['uniqueBrowsersCount'] = uniqueBrowsers.count

      report['totalSessions'] = sessions.count

      report['allBrowsers'] = uniqueBrowsers.sort.join(',')

      # Статистика по пользователям
      users_objects = []

      users.each do |user|
        attributes = user
        user_sessions = sessions.select { |session| session.user_id == user.id }
        users_objects.push(sessions: user_sessions, user: user)
      end

      report['usersStats'] = {}

      # Собираем количество сессий по пользователям
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'sessionsCount' => sessions.count }
      end

      # Собираем количество времени по пользователям
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'totalTime' => sessions.sum(&:duration_minutes).to_s + ' min.' }
      end

      # Выбираем самую длинную сессию пользователя
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'longestSession' => sessions.map(&:duration_minutes).max.to_s + ' min.' }
      end

      # Браузеры пользователя через запятую
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'browsers' => sessions.map(&:browser).sort.join(', ') }
      end

      # Хоть раз использовал IE?
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'usedIE' => sessions.any?(&:is_ie?) }
      end

      # Всегда использовал только Chrome?
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'alwaysUsedChrome' =>  sessions.all?(&:is_chrome?) }
      end

      # Даты сессий через запятую в обратном порядке в формате iso8601
      collect_stats_from_users(report, users_objects) do |sessions|
        { 'dates' => sessions.map(&:date).sort.reverse }
      end

      File.write(output_file_path, "#{report.to_json}\n")
    end

    private

    def collect_stats_from_users(report, users_objects, &block)
      users_objects.each do |user_object|
        user, sessions = user_object.values_at(:user, :sessions)
        user_key = user.full_name
        report['usersStats'][user_key] ||= {}
        report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(sessions))
      end
    end
  end
end