require 'browser_data_parser/session'
require 'browser_data_parser/user'
require_relative 'fixtures'

module Factories
  def create(fixture_name, **attrs)
    model_class = fixture_name.to_s.include?('session') ? BrowserDataParser::Session : BrowserDataParser::User
    model_class.new(Fixtures.send("#{fixture_name}_fixture", **attrs))
  end
end
