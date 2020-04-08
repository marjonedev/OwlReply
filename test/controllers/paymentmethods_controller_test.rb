require 'test_helper'

class PaymentmethodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    @paymentmethod = paymentmethods(:one)
  end

  test "should get index" do
    get paymentmethods_url
    assert_response :success
  end

  test "should get new" do
    get new_paymentmethod_url
    assert_response :success
  end

  test "should create paymentmethod" do
    assert_difference('Paymentmethod.count') do
      post paymentmethods_url, params: { paymentmethod: { card_exp_date: @paymentmethod.card_exp_date, card_name: @paymentmethod.card_name, card_type: @paymentmethod.card_type, customer_id: @paymentmethod.customer_id, method: @paymentmethod.method, user_id: @paymentmethod.user_id } }
    end

    assert_redirected_to paymentmethod_url(Paymentmethod.last)
  end

  test "should show paymentmethod" do
    get paymentmethod_url(@paymentmethod)
    assert_response :success
  end

  test "should get edit" do
    get edit_paymentmethod_url(@paymentmethod)
    assert_response :success
  end

  test "should update paymentmethod" do
    patch paymentmethod_url(@paymentmethod), params: { paymentmethod: { card_exp_date: @paymentmethod.card_exp_date, card_name: @paymentmethod.card_name, card_type: @paymentmethod.card_type, customer_id: @paymentmethod.customer_id, method: @paymentmethod.method, user_id: @paymentmethod.user_id } }
    assert_redirected_to paymentmethod_url(@paymentmethod)
  end

  test "should destroy paymentmethod" do
    assert_difference('Paymentmethod.count', -1) do
      delete paymentmethod_url(@paymentmethod)
    end

    assert_redirected_to paymentmethods_url
  end
end
