# lib/sequel_auth/tasks/install.rake
require 'rake'

namespace :sequel_auth do
  desc 'Install SequelAuth files (views, migrations)'
  task :install do
    puts 'Installing SequelAuth files...'
    SequelAuth::Generator::InstallGenerator.new(Dir.pwd).install
    puts 'Done!'
  end
end
