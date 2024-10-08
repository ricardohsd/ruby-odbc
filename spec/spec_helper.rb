# frozen_string_literal: true

require "odbc"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    @dsn = "mysql"
    @uid = "ruby_odbc"
    @pwd = "ruby_odbc"
  end
end
