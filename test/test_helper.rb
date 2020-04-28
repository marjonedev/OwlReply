ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def setup_everything_necessary
    host! "https://www.owlreply.com"
    create_the_basic_subscription
    # create_the_first_user
    @user = users(:username1)
    User.all.each{|user|user.password="nothing123";user.save!}
  end

  def setup_everything_necessary!
    setup_everything_necessary
    post login_url, params: {'user[username]': User.first.username, 'user[password]': 'nothing123'}
  end

  def setup_everything_with_admin!
    setup_everything_necessary
    @user = users(:username3)
    post login_url, params: {'user[username]': @user.username, 'user[password]': 'nothing123'}
  end

  def login
    @current_user = User.first
  end

  def create_the_basic_subscription
    sub = Subscription.where(name: "Entrepreneur")
    unless sub.any?
      Subscription.create([id: 1, name: "Entrepreneur", price: 0, frequency: "Monthly"])
    end
  end

  def create_the_first_user
    @user = users(:username1)

    post users_url, params: { user: { email_address: @user.email_address, encrypted_password: @user.encrypted_password, salt: @user.salt, username: @user.username } }
  end

  def is_main_emailaccount(account)
    @user.email_address == account.address
  end

  def create_stripe_token(cardno: '4242424242424242', exp_month: 4, exp_year: 2021, cvc: '321')

    Stripe.api_key = Rails.application.credentials.stripe_api_key

    Stripe::Token.create({
                             card: {
                                 number: cardno,
                                 exp_month: exp_month,
                                 exp_year: exp_year,
                                 cvc: cvc,
                             },
                         })
  end

  def create_paymentmethod()
    @paymentmethod = paymentmethods(:one)

    token = create_stripe_token(cardno: @paymentmethod.card_number, exp_month: @paymentmethod.card_exp_month, exp_year: @paymentmethod.card_exp_year)

    post paymentmethods_url, params: {
        paymentmethod: {
            token: token.id,
            default: true,
            card_number: @paymentmethod.card_number,
            card_exp_month: @paymentmethod.card_exp_month,
            card_exp_year: @paymentmethod.card_exp_year,
            card_brand: @paymentmethod.card_brand,
            customer_id: @paymentmethod.customer_id,
            currency: @paymentmethod.currency
        }
    }, xhr: true

  end

  def create_user_invoice

    @user = users(:username1)
    @sub = subscriptions(:three)
    create_paymentmethod
    @user.invoices.create({ subscription_id: @sub.id })

  end

  # Add more helper methods to be used by all tests here...
end
