ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def login
    @current_user = User.first
  end

  def create_the_basic_subscription
    Subscription.create(id: 1, name: "Entrepreneur", price: 0, frequency: "Monthly")
  end

  def create_the_first_user
    @user = users(:one)
    post users_url, params: { user: { email_address: @user.email_address, encrypted_password: @user.encrypted_password, salt: @user.salt, username: @user.username } }
  end

  # Add more helper methods to be used by all tests here...
end
