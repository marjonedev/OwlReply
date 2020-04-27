require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:username1)
    User.all.each{|user|user.password="nothing123456789";user.save!}
  end

  test "should forgot with blank password" do
    post password_forgot_url, params: {user: {email_address: ''}}, as: :json
    assert_response :not_found
  end

  test "should forgot password" do
    post password_forgot_url, params: {user: {email_address: @user.email_address}}
    assert_redirected_to login_url
  end

  test "should not forgot with invalid user" do
    post password_forgot_url, params: {user: {email_address: 'someone5@example.com'}}, as: :json
    assert_response :not_found
  end

  test "should reset password" do
    post password_forgot_url, params: {user: {email_address: @user.email_address}}

    user = User.find(@user.id)
    post password_reset_submit_url, params: {user: {token: user.reset_password_token, password: 'nothing123456789'} }

    assert_redirected_to login_url
  end

  test "should not reset with invalid token" do
    post password_reset_submit_url, params: {user: {token: 'invalidtoken1233', password: 'nothing123456789'} }

    assert_response :success
    assert_equal "text/javascript", @response.media_type
  end
end
