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

end