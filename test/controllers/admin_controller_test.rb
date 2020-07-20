require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    setup_everything_necessary!
  end

  test "no access from non admin" do
    assert_raise(ActionController::RoutingError) do
      post '/admin'
      follow_redirect!
    end
    assert_raise(ActionController::RoutingError) do
      get '/admin'
      follow_redirect!
    end
  end

  test "no account view from non admin" do
    assert_raise(ActionController::RoutingError) do
      post admin_accounts_url
      follow_redirect!
    end
    get admin_accounts_url
    assert_response :redirect
    follow_redirect!
    assert_equal "/", path
  end

  test "admin view accounts" do
    setup_everything_with_admin!
    get admin_accounts_url
    assert_response :success
  end

  test "admin view emailaccounts of a user" do
    setup_everything_with_admin!
    @user = users(:username1)
    get "/admin/accounts/#{@user.id}/emailaccounts"
    assert_response :success
  end

  test "admin view emailaccount" do
    setup_everything_with_admin!
    @emailaccount = emailaccounts(:email1)
    get "/admin/emailaccounts/#{@emailaccount.id}"
    assert_response :success
  end

  test "admin view emailaccounts" do
    setup_everything_with_admin!
    get admin_emailaccounts_url
    assert_response :success
  end

  test "admin view replies" do
    setup_everything_with_admin!
    get admin_replies_url
    assert_response :success
  end

  test "admin view subscribers" do
    setup_everything_with_admin!
    get admin_subscribers_url
    assert_response :success
  end

  test "admin view late_invoices" do
    setup_everything_with_admin!
    get admin_late_invoices_url
    assert_response :success
  end

  test "admin view show_invoice" do
    setup_everything_with_admin!
    @invoice = invoices(:one)
    get "/admin/show_invoice/#{@invoice.id}"
    assert_response :success
  end

end