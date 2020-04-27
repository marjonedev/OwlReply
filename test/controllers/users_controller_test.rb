require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:username1)
  end

  test "should get index" do
    setup_everything_with_admin!
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      create_the_basic_subscription
      post users_url, params: { user: { email_address: 'someone4@example.com', password: 'nothing123', salt: 'MyString', username: 'username4'} }
    end

    assert_redirected_to "/wizard/1"
  end

  test "should show user" do
    setup_everything_necessary!
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    setup_everything_necessary!
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    setup_everything_necessary!
    patch user_url(@user), params: { user: { email_address: @user.email_address, password: @user.password, salt: @user.salt, username: @user.username } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
