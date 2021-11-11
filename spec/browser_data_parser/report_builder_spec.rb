require 'browser_data_parser/report_builder'

RSpec.describe BrowserDataParser::ReportBuilder do
  let(:builder) { described_class.new }
  let(:report) { builder.finalize_report }

  describe '#finalize_report' do
    it 'returns default data if nothing was added' do
      expect(report['uniqueBrowsersCount']).to eq(0)
      expect(report['allBrowsers']).to eq('')
      expect(report['totalSessions']).to eq(0)
      expect(report['totalUsers']).to eq(0)
      expect(report['usersStats']).to eq({})
    end

    it 'resets current user stats' do
      user = create(:user)
      builder.current_user = user
      builder.finalize_report
      builder.add_session(create(:session))
      report = builder.finalize_report

      expect(report['usersStats'][user.full_name]['sessionsCount']).to eq(0)
    end
  end

  describe '#add_session' do
    it 'adds session data to the report' do
      session = create(:session)
      builder.add_session(session)

      expect(report['uniqueBrowsersCount']).to eq(1)
      expect(report['allBrowsers']).to eq(session.browser)
      expect(report['totalSessions']).to eq(1)
    end

    it 'sorts unique browsers in alphabetical order' do
      abc_session = create(:session, browser: "Abc")
      xyz_session = create(:session, browser: 'Xyz')
      builder.add_session(xyz_session)
      builder.add_session(abc_session)

      expect(report['uniqueBrowsersCount']).to eq(2)
      expect(report['allBrowsers']).to eq("#{abc_session.browser},#{xyz_session.browser}")
    end

    it 'does not count same browser twice' do
      session = create(:session)
      2.times { builder.add_session(session) }

      expect(report['uniqueBrowsersCount']).to eq(1)
      expect(report['allBrowsers']).to eq(session.browser)
    end
  end

  describe '#current_user=' do
    let(:user) { create(:user) }

    def get_user_stats(user)
      report['usersStats'][user.full_name]
    end

    it "adds user sessions durations data to the report" do
      builder.current_user = user
      builder.add_session(create(:session, duration_minutes: 2))
      builder.add_session(create(:session, duration_minutes: 15))

      user_stats = get_user_stats(user)
      expect(report['totalUsers']).to eq(1)
      expect(user_stats['sessionsCount']).to eq(2)
      expect(user_stats['totalTime']).to eq("17 min.")
      expect(user_stats['longestSession']).to eq("15 min.")
    end

    it 'adds browser info data to the report' do
      builder.current_user = user
      session_1 = create(:session, browser: 'custom 1')
      session_2 = create(:session, browser: 'custom 2')
      builder.add_session(session_2)
      builder.add_session(session_1)

      user_stats = get_user_stats(user)
      expect(user_stats['browsers']).to eq("#{session_1.browser}, #{session_2.browser}")
      expect(user_stats['usedIE']).to eq(false)
      expect(user_stats['alwaysUsedChrome']).to eq(false)
    end

    it 'sets usedIE: true if there is at least one IE session' do
      builder.current_user = user
      builder.add_session(create(:ie_session))
      builder.add_session(create(:chrome_session))

      user_stats = get_user_stats(user)
      expect(user_stats['usedIE']).to eq(true)
      expect(user_stats['alwaysUsedChrome']).to eq(false)
    end

    it 'sets alwaysUsedChrome: true if user only used chrome' do
      builder.current_user = user
      builder.add_session(create(:chrome_session))

      expect(get_user_stats(user)['alwaysUsedChrome']).to eq(true)
    end

    it 'reverse sorts session dates' do
      builder.current_user = user
      session_2020 = create(:session, date: '2020-02-03')
      session_2021 = create(:session, date: '2021-01-01')
      builder.add_session(session_2020)
      builder.add_session(session_2021)

      expect(get_user_stats(user)['dates']).to eq([session_2021.date, session_2020.date])
    end

    it 'dumps current user sessions' do
      user_1 = create(:user, first_name: 'John 1')
      user_2 = create(:user, first_name: 'John 2')

      builder.current_user = user_1
      builder.add_session(create(:session))

      builder.current_user = user_2
      builder.add_session(create(:session))

      expect(get_user_stats(user_1)['sessionsCount']).to eq(1)
      expect(get_user_stats(user_2)['sessionsCount']).to eq(1)
    end
  end
end
