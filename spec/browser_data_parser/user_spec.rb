require 'browser_data_parser/user'

RSpec.describe BrowserDataParser::User do
  describe '#initialize' do
    it 'parses user data' do
      user = described_class.new(user_fixture(id: 123, first_name: "Foo", last_name: "Bar"))

      expect(user.id).to eq(123)
      expect(user.first_name).to eq("Foo")
      expect(user.last_name).to eq("Bar")
      expect(user.full_name).to eq("Foo Bar")
    end
  end
end
