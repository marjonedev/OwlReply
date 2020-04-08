require 'test_helper'

class EmailaccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!

    @emailaccount = emailaccounts(:email1)
  end

  test "should get index" do
    get emailaccounts_url
    assert_response :success
  end

  test "should get new" do
    get new_emailaccount_url
    assert_response :success
  end

  test "should create emailaccount" do
    assert_difference('Emailaccount.count') do
      post emailaccounts_url, params: { emailaccount: { address: @emailaccount.address, encrypted_password: @emailaccount.encrypted_password, encryption_key: @emailaccount.encryption_key, password: @emailaccount.password, user_id: @emailaccount.user_id } }
    end

    assert_redirected_to emailaccount_url(Emailaccount.last)
  end

  test "should show emailaccount" do
    get emailaccount_url(@emailaccount)
    assert_response :success
  end

  test "should get edit" do
    get edit_emailaccount_url(@emailaccount)
    assert_response :success
  end

  test "should update emailaccount" do
    patch emailaccount_url(@emailaccount), params: { emailaccount: { address: @emailaccount.address, encrypted_password: @emailaccount.encrypted_password, encryption_key: @emailaccount.encryption_key, password: @emailaccount.password, user_id: @emailaccount.user_id } }
    assert_redirected_to emailaccount_url(@emailaccount)
  end

  test "should destroy emailaccount" do
    assert_difference('Emailaccount.count', -1) do
      delete emailaccount_url(@emailaccount)
    end

    assert_redirected_to emailaccounts_url
  end
end
