# lib/sequel_auth/models/user.rb
require 'bcrypt'

class User < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps

  def validate
    super
    validates_presence %i[username email password_digest]
    validates_unique %i[username email]
    validates_format(/\A[^@\s]+@[^@\s]+\z/, :email)
    validates_min_length 1, :username
    validates_max_length 20, :username
    validates_min_length 6, :password if new? || password_changed?
    validates_max_length 20, :password if new? || password_changed?
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = BCrypt::Password.create(new_password)
  end

  attr_reader :password

  def password_changed?
    !@password.nil?
  end

  def match_password(input_password)
    BCrypt::Password.new(password_digest) == input_password
  end

  def self.authenticate(username_or_email, password)
    user = where(email: username_or_email).first ||
           where(username: username_or_email).first

    user && user.match_password(password) ? user : nil
  end
end
