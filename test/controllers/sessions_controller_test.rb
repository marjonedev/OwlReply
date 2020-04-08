require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  #test "should get new" do
    #get sessions_new_url
    #assert_response :success
  #end
  setup do
    setup_everything_necessary
  end

  test "should login" do
    post '/login', params: {'user[username]': User.first.username, 'user[password]': 'nothing123'}
    follow_redirect!
    assert_equal "/", path
  end

end
