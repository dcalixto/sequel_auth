require 'rake'
require 'sequel'
require 'logger'
require 'yaml'
require 'bundler/setup'
Bundler.require

namespace :db do
  desc 'Run migrations'
  task :migrate do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end
