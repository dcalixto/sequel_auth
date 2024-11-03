# lib/sequel_auth/helpers.rb
module SequelAuth
  module Helpers
    def current_user
      @current_user ||= User[session[:user_id]] if session[:user_id]
    end

    def signed_in?
      !current_user.nil?
    end

    def authenticate!
      redirect '/login' unless signed_in?
    end
  end
end
