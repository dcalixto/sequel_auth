# lib/sequel_auth/middleware.rb
require 'sinatra'
require 'sequel'
require 'bcrypt'

module SequelAuth
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # Session management or other middleware logic, if needed
      @app.call(env)
    end
  end
end
