# example/config.ru
require 'bundler/setup'
require 'sinatra/base'
require 'sequel_auth'

class ExampleApp < Sinatra::Base
  enable :sessions

  helpers SequelAuth::Helpers
  register SequelAuth::Routes

  get '/' do
    if signed_in?
      "Welcome #{current_user.username}!"
    else
      "Please <a href='/login'>login</a> or <a href='/signup'>signup</a>"
    end
  end
end

run ExampleApp
