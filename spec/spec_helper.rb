require 'bundler/setup'
require 'sequel'
require 'database_cleaner/sequel'

# Configure test database
DB = Sequel.connect('sqlite://test.db')
Sequel::Model.db = DB

# Run migrations
Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations')

require_relative '../lib/sequel_auth'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Database Cleaner configuration with specific DB
  DatabaseCleaner[:sequel, db: DB].strategy = :transaction

  config.before(:suite) do
    DatabaseCleaner[:sequel, db: DB].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner[:sequel, db: DB].cleaning do
      example.run
    end
  end
end
