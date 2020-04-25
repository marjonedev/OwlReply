require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  test "should show home for admin" do
    setup_everything_with_admin!
    get root_url
    assert_response :success
  end

  test "should show home for admin with one emailaccount" do

  end

  test "should show home for admin with many emailaccount" do

  end

  test "show get for non admin" do

  end

  test "should get home" do
    get root_url
    assert_response :success
  end

  test "should get help" do
    get help_url
    assert_response :success
  end

  test "should get features" do
    get features_url
    assert_response :success
  end

  test "should get pricing" do
    get pricing_url
    assert_response :success
  end

  test "should get signup" do
    get signup_url
    assert_response :success
  end

  test "should get documentation" do
    get documentation_url
    assert_response :success
  end

  test "should get faqs" do
    get faqs_url
    assert_response :success
  end

  test "should get security" do
    get security_url
    assert_response :success
  end

  test "should get terms" do
    get "/terms-of-use"
    assert_response :success
  end

  test "should get privacy" do
    get "/privacy-policy"
    assert_response :success
  end

  test "should get guide_email_automation" do
    get "/guides/email-automation"
    assert_response :success
  end

  test "should get guide_customer_service_emails" do
    get "/guides/customer-service-emails"
    assert_response :success
  end

  test "should get guide_tips_for_good_emails" do
    get "/guides/tips-for-good-emails"
    assert_response :success
  end



end