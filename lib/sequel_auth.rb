# lib/sequel_auth.rb
require 'bcrypt'
require 'sequel'
require 'securerandom'

module SequelAuth
  def self.included(base)
    base.plugin :validation_helpers
    base.plugin :timestamps, update_on_create: true
    base.attr_accessor :password # For setting password directly

    # Add any additional setup or configuration here if needed
  end

  # Override Sequel's `before_save` to hash the password before saving
  def before_save
    if @password
      self.password_digest = BCrypt::Password.create(@password)
      @password = nil # Clear the plaintext password after hashing
    end
    super
  end

  # Define model validations
  def validate
    super
    validates_presence [:email]
    validates_presence [:password] if new? # Only require password for new records
    validates_format(/\A[^@\s]+@[^@\s]+\z/, :email) if email
    validates_unique :email
  end

  # Authenticate the user by comparing stored password hash with input password
  def authenticate(password)
    return false unless password_digest

    BCrypt::Password.new(password_digest) == password && self
  end

  # Generate a reset token for password recovery
  def generate_reset_token
    token = SecureRandom.hex(32)
    update(
      reset_token_digest: BCrypt::Password.create(token),
      reset_token_expires_at: Time.now + 3600 # Expires in 1 hour
    )
    token
  end

  # Check if the provided reset token is valid
  def valid_reset_token?(token)
    return false unless reset_token_digest && reset_token_expires_at
    return false if reset_token_expires_at < Time.now # Token has expired

    BCrypt::Password.new(reset_token_digest) == token
  end

  # Reset the user's password if the token is valid
  def reset_password(new_password, token)
    return false unless valid_reset_token?(token)

    self.password = new_password
    self.reset_token_digest = nil
    self.reset_token_expires_at = nil
    save_changes
    true
  end
end
