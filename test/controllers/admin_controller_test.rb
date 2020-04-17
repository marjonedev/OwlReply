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
      post '/admin/accounts'
      follow_redirect!
    end
    get '/admin/accounts'
    assert_response :redirect
    follow_redirect!
    assert_equal "/", path
  end

  test "should get accounts" do
    get admin_accounts_url
    follow_redirect!
  end

  test "should get emailaccounts" do
    get admin_emailaccounts_url
    follow_redirect!
  end

  test "should get replies" do
    get admin_replies_url
    follow_redirect!
  end

  test "should get subscribers" do
    get admin_subscribers_url
    follow_redirect!
  end

  test "should get late_invoices" do
    get admin_late_invoices_url
    follow_redirect!
  end

  test "should get show_invoice" do
    @invoice = invoices(:one)
    get "/admin/show_invoice/#{@invoice.id}"
    follow_redirect!
  end

end