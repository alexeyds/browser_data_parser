require 'browser_data_parser/session'

RSpec.describe BrowserDataParser::Session do
  describe '#initialize' do
    it 'parses session data' do
      session = described_class.new(session_fixture(id: 1, user_id: 3, browser: "Chrome 23", duration_minutes: 32, date: "2020-03-28"))

      expect(session.id).to eq(1)
      expect(session.user_id).to eq(3)
      expect(session.browser).to eq("CHROME 23")
      expect(session.duration_minutes).to eq(32)
      expect(session.date).to eq(Date.new(2020, 3, 28))
    end
  end

  describe "#is_ie?" do
    it 'returns true if browser is IE' do
      session = described_class.new(ie_session_fixture)
      expect(session.is_ie?).to eq(true)
    end

    it 'returns false if browser is not IE' do
      session = described_class.new(chrome_session_fixture)
      expect(session.is_ie?).to eq(false)
    end
  end

  describe "#is_chrome?" do
    it 'returns true if browser is Chrome' do
      session = described_class.new(chrome_session_fixture)
      expect(session.is_chrome?).to eq(true)
    end

    it 'returns false if browser is not Chrome' do
      session = described_class.new(ie_session_fixture)
      expect(session.is_chrome?).to eq(false)
    end
  end
end
