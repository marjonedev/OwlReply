require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get '/login'
    assert_response :success
  end

  test "should login" do
    setup_everything_necessary
    post '/login', params: {'user[username]': User.first.username, 'user[password]': 'nothing123'}
    follow_redirect!
    assert_equal "/", path
  end

  test "should logout" do
    setup_everything_necessary!
    post '/login', params: {'user[username]': User.first.username, 'user[password]': 'nothing123'}
    follow_redirect!
    assert_equal "/", path
  end

end
