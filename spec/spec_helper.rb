# frozen_string_literal: true
require_relative 'fixtures'
require_relative 'factories'

RSpec.configure do |config|
  config.include Fixtures
  config.include Factories

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
