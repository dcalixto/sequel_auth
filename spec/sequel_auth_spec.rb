require 'spec_helper'
require 'sequel_auth'
require 'bcrypt'

RSpec.describe SequelAuth do
  DB = Sequel.connect('sqlite://test.db')

  before(:all) do
    # Create the users table with necessary columns for the tests if it doesn't exist
    DB.create_table?(:users) do
      primary_key :id
      String :email, null: false, unique: true
      String :username
      String :password_digest
      String :reset_token_digest
      DateTime :reset_token_expires_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  after(:all) do
    DB.drop_table?(:users)
  end

  before(:each) do
    # Clear out the users table before each test for a clean slate
    DB[:users].delete
  end

  let(:user_class) do
    Class.new(Sequel::Model(DB[:users])) do
      include SequelAuth
      set_dataset :users
    end
  end

  describe 'authentication' do
    let(:user) { user_class.create(email: 'test@example.com', username: 'testuser', password: 'password123') }

    it 'creates a password digest when setting password' do
      expect(user.password_digest).not_to be_nil
    end

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'returns false for incorrect password' do
      expect(user.authenticate('wrong_password')).to be false
    end
  end

  describe 'validations' do
    it 'requires email' do
      user = user_class.new(password: 'password123')
      expect(user.valid?).to be false
      expect(user.errors).to include(:email)
    end

    it 'requires password for new records' do
      user = user_class.new(email: 'test@example.com')
      expect(user.valid?).to be false
      expect(user.errors).to include(:password)
    end

    it 'requires unique email' do
      user_class.create(email: 'test@example.com', username: 'testuser', password: 'password123')
      duplicate_user = user_class.new(email: 'test@example.com', username: 'anotheruser', password: 'password123')
      expect(duplicate_user.valid?).to be false
      expect(duplicate_user.errors).to include(:email)
    end
  end

  describe 'password reset' do
    let(:user) { user_class.create(email: 'test@example.com', username: 'testuser', password: 'password123') }

    it 'generates reset token' do
      token = user.generate_reset_token
      expect(token).not_to be_nil
      expect(user.reset_token_digest).not_to be_nil
    end

    it 'validates reset token' do
      token = user.generate_reset_token
      expect(user.valid_reset_token?(token)).to be true
      expect(user.valid_reset_token?('wrong_token')).to be false
    end

    it 'resets password with valid token' do
      token = user.generate_reset_token
      expect(user.reset_password('new_password', token)).to be true
      expect(user.authenticate('new_password')).to eq(user)
    end
  end

  describe 'hooks' do
    it 'sets created_at on create' do
      user = user_class.create(email: 'test@example.com', username: 'testuser', password: 'password123')
      expect(user.created_at).not_to be_nil
    end

    it 'updates updated_at on save' do
      user = user_class.create(email: 'test@example.com', username: 'testuser', password: 'password123')
      original_updated_at = user.updated_at
      sleep(1) # Ensuring there's a measurable time difference
      user.update(email: 'new@example.com')
      expect(user.updated_at).to be > original_updated_at
    end
  end
end
