require 'rake'
require 'rspec/core/rake_task'

# Import the sequel_auth tasks
import 'lib/sequel_auth/tasks/install.rake'

# Define RSpec task
RSpec::Core::RakeTask.new(:spec)

# Set default task to run specs
task default: :spec
