module BrowserDataParser
  class ReportBuilder
    def initialize
      @current_user = nil
      @current_user_sessions = []
      @users_count = 0
      @unique_browsers = []
      @sessions_count = 0
      @user_sessions_data = {}
    end

    def current_user=(user)
      maybe_dump_current_user_sessions_data
      @users_count += 1
      @current_user = user
    end

    def add_session(session)
      @current_user_sessions.push(session)
      @unique_browsers.push(session.browser) unless @unique_browsers.include?(session.browser)
      @sessions_count += 1
    end

    def finalize_report
      maybe_dump_current_user_sessions_data

      {
        'totalUsers' => @users_count,
        'uniqueBrowsersCount' => @unique_browsers.count,
        'totalSessions' => @sessions_count,
        'allBrowsers' => @unique_browsers.sort.join(','),
        'usersStats' => @user_sessions_data
      }
    end

    private

    def maybe_dump_current_user_sessions_data
      if @current_user
        @user_sessions_data[@current_user.full_name] = current_user_sessions_data
        @current_user_sessions = []
        @current_user = nil
      end
    end

    def current_user_sessions_data
      sessions = @current_user_sessions

      {
        'sessionsCount' => sessions.count,
        'totalTime' => minutes_text(sessions.sum(&:duration_minutes)),
        'longestSession' => minutes_text(sessions.map(&:duration_minutes).max),
        'browsers' => sessions.map(&:browser).sort.join(', '),
        'usedIE' => sessions.any?(&:is_ie?),
        'alwaysUsedChrome' => sessions.all?(&:is_chrome?),
        'dates' => sessions.map(&:date).sort.reverse
      }
    end

    def minutes_text(n)
      "#{n} min."
    end
  end
end
