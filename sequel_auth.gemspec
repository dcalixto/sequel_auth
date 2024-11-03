# sequel_auth.gemspec
Gem::Specification.new do |spec|
  spec.name          = 'sequel_auth'
  spec.version       = '0.1.0'
  spec.authors       = ['Daniel Calixto']
  spec.email         = ['calixtodaniel@gmail.com']
  spec.summary       = 'Authentication gem for Sinatra or Roda with Sequel'
  spec.description   = 'A simple authentication system for Sinatra or Roda applications, using Sequel ORM for database interactions.'
  spec.homepage      = 'https://github.com/dcalixto/sequel_auth'
  spec.license       = 'MIT'

  spec.files = Dir[
    'lib/**/*',
    'templates/**/*',
    'Rakefile',
    'README.md'
  ]
  spec.require_paths = ['lib']
  spec.add_dependency 'bcrypt'
  spec.add_dependency 'sequel'
end
