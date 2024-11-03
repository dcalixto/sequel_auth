# SequelAuth

A simple, secure authentication gem for Sinatra and Roda applications using Sequel ORM.
Provides user authentication with email/username login, secure password handling, and customizable views.

[![Build Status](https://app.travis-ci.com/dcalixto/sequel_auth.svg?token=eZ8xZn3yqKudZ5sNxRYM&branch=master)](https://app.travis-ci.com/dcalixto/sequel_auth)
[![Maintainability](https://api.codeclimate.com/v1/badges/b9109f665afed8a96d4e/maintainability)](https://codeclimate.com/github/dcalixto/sequel_auth/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b9109f665afed8a96d4e/test_coverage)](https://codeclimate.com/github/dcalixto/sequel_auth/test_coverage)

## Security Features

- Secure password storage using BCrypt
- Protection against timing attacks in password comparison
- Session-based authentication
- Password length and complexity validation
- Protection against username enumeration
- IP tracking for login attempts
- Last login timestamp tracking
- SQL injection protection through Sequel ORM
- CSRF protection support
- Secure password reset functionality (via email)
- No stored plaintext passwords
- Input sanitization and validation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel_auth'
```

Then execute:

```bash
$ bundle install
```

After installation, run the installer:

```bash
$ rake sequel_auth:install
```

This will:

- Create auth views in `views/auth/`
- Add user migration to `db/migrations/`
- Set up necessary routes and helpers

## Database Setup

Run your migrations to create the users table:

```bash
$ rake db:migrate
```

## Usage

### Sinatra Setup

```ruby
# app.rb
require 'sinatra/base'
require 'sequel_auth'

class YourApp < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] # Important: Set this to a secure value

  # Optional: Enable CSRF protection
  set :protection, except: [:http_origin]

  # Register SequelAuth
  helpers SequelAuth::Helpers
  register SequelAuth::Routes

  # Protect routes that require authentication
  before '/protected/*' do
    authenticate!
  end

  # Your routes here...
end
```

### Roda Setup

```ruby
# app.rb
require 'roda'
require 'sequel_auth'

class YourApp < Roda
  plugin :sessions, secret: ENV['SESSION_SECRET']
  plugin :render
  plugin :flash

  # Include SequelAuth helpers
  include SequelAuth::Helpers

  route do |r|
    # Include authentication routes
    r.on 'auth' do
      r.on 'signup' do
        r.get { view 'auth/signup' }

        r.post do
          # Signup logic (provided by SequelAuth)
        end
      end

      # Other auth routes...
    end

    # Protect routes
    r.on 'protected' do
      authenticate!
      # Your protected routes...
    end
  end
end
```

## Helper Methods

```ruby
# Check if user is logged in
signed_in?

# Get current user
current_user

# Require authentication
authenticate!
```

## Views

SequelAuth provides default views that you can customize:

- `views/auth/login.erb`
- `views/auth/signup.erb`

## Configuration

Configure SequelAuth in an initializer:

```ruby
SequelAuth.configure do |config|
  # Custom User class name (default: 'User')
  config.user_class = 'Member'

  # Custom session key (default: :user_id)
  config.session_key = :member_id
end
```

## User Model Features

```ruby
# Create a new user
User.create(
  email: 'user@example.com',
  username: 'username',
  password: 'password',
)

# Authenticate a user
user = User.authenticate('username_or_email', 'password')

# Check if password matches
user.match_password('password')

# Update password
user.password = 'new_password'
user.save
```

## Security Best Practices

1. **Session Security**
   - Always set a strong `session_secret`
   - Enable SSL in production
   - Use secure session settings

```ruby
set :sessions, httponly: true, secure: production?, expire_after: 31_557_600 # 1 year
```

2. **Password Requirements**

   - Minimum length: 6 characters
   - Maximum length: 20 characters
   - Validates complexity

3. **Rate Limiting**
   - Implement rate limiting for login attempts
   - Track IP addresses
   - Log suspicious activity

## Example Protected Route

```ruby
# Sinatra
get '/dashboard' do
  authenticate!
  "Welcome #{current_user.username}!"
end

# Roda
r.get 'dashboard' do
  authenticate!
  "Welcome #{current_user.username}!"
end
```

## Testing

Run the test suite:

```bash
$ rake test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Security Issues

Please report security issues via email to security@yourgem.com rather than creating a public issue.
