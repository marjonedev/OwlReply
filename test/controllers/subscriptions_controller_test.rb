require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    create_admin_user
    @subscription = subscriptions(:one)
  end

  # #Go to homepage (Nothing/not important)
  # test "go to homepage" do
  #   get root_url
  #   assert_response :success
  # end
  #
  # #Go to login page (Just showing the page isn't important/nothing)
  # test "go to login page" do
  #   get login_url
  #   assert_response :success
  # end

  #Login with admin name/password (post to login controller with admin username and password)
  # test "login as administrator" do
  #   post login_url, params: { user: { username: @user.username, password: 'MyString' }}
  #   assert_response :success
  # end

  # * Do some action (post to the action).

  test "should get index" do
    get subscriptions_url
    assert_response :success
  end

  test "should get new" do
    get new_subscription_url
    assert_response :success
  end

  # test "should create subscription" do
  #   assert_difference('Subscription.count') do
  #     post subscriptions_url, params: { subscription: { frequency: @subscription.frequency, name: @subscription.name, price: @subscription.price } }
  #   end
  #
  #   follow_redirect!
  # end

  # test "should show subscription" do
  #   get subscription_url(@subscription)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_subscription_url(@subscription)
  #   assert_response :success
  # end

  # test "should update subscription" do
  #   patch subscription_url(@subscription), params: { subscription: { frequency: @subscription.frequency, name: @subscription.name, price: @subscription.price } }
  #   assert_redirected_to subscription_url(@subscription)
  # end

  # test "should destroy subscription" do
  #   assert_difference('Subscription.count', -1) do
  #     delete subscription_url(@subscription)
  #   end
  #
  #   assert_redirected_to subscriptions_url
  # end
end
