# lib/sequel_auth/routes.rb
# For Sinatra
module SequelAuth
  module Routes
    def self.registered(app)
      app.get '/signup' do
        erb :signup
      end

      app.post '/signup' do
        @user = User.new(
          email: params[:email],
          username: params[:username],
          password: params[:password]
        )

        if @user.save
          session[:user_id] = @user.id
          redirect '/'
        else
          erb :signup
        end
      end

      app.get '/login' do
        redirect '/' if signed_in?
        erb :login
      end

      app.post '/login' do
        user = User.authenticate(params[:username_or_email], params[:password])

        if user
          user.update(
            login_at: Time.now,
            ip_address: request.ip
          )
          session[:user_id] = user.id
          redirect '/'
        else
          @error = 'Invalid email/username or password'
          erb :login
        end
      end

      app.get '/logout' do
        session[:user_id] = nil
        redirect '/login'
      end
    end
  end
end
