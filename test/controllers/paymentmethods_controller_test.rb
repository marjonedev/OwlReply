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

      create_paymentmethod

      # post paymentmethods_url, params: {
      #     paymentmethod: {
      #         token: token.id,
      #         default: true,
      #         card_number: @paymentmethod.card_number,
      #         card_exp_month: @paymentmethod.card_exp_month,
      #         card_exp_year: @paymentmethod.card_exp_year,
      #         card_brand: @paymentmethod.card_brand,
      #         customer_id: @paymentmethod.customer_id,
      #         currency: @paymentmethod.currency
      #     }
      # }
    end

    assert_redirected_to root_url
  end

  test "should show paymentmethod" do
    @paymentmethod = create_paymentmethod
    get paymentmethod_url(@paymentmethod)
    assert_response :success
  end

  test "should get edit" do
    @paymentmethod = create_paymentmethod
    get edit_paymentmethod_url(@paymentmethod)
    assert_response :success
  end

  test "should update paymentmethod" do
    @paymentmethod = create_paymentmethod
    @paymentmethod2 = paymentmethods(:two)

    @paymentmethod.update(default: true,
      card_number: @paymentmethod2.card_number,
      card_exp_month: @paymentmethod2.card_exp_month,
      card_exp_year: @paymentmethod2.card_exp_year,
      card_brand: @paymentmethod2.card_brand,
      customer_id: @paymentmethod2.customer_id,
      currency: @paymentmethod2.currency
    )

    assert_redirected_to root_url
  end

  test "should destroy paymentmethod" do
    @paymentmethod = create_paymentmethod
    assert_difference 'Paymentmethod.count', -1 do
      delete paymentmethod_url(@paymentmethod)
    end

    assert_redirected_to paymentmethods_url
  end
end
