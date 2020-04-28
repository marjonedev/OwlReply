require 'test_helper'

class PaymentmethodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    @paymentmethod = paymentmethods(:one)
  end

  teardown do
    @paymentmethod = nil
    Paymentmethod.destroy_all
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

      # create_paymentmethod @user

      token = create_stripe_token(cardno: @paymentmethod.card_number, exp_month: @paymentmethod.card_exp_month, exp_year: @paymentmethod.card_exp_year)

      post paymentmethods_url, params: {
          paymentmethod: {
              token: token.id,
              default: true,
              card_number: @paymentmethod.card_number,
              card_exp_month: @paymentmethod.card_exp_month,
              card_exp_year: @paymentmethod.card_exp_year,
              card_brand: @paymentmethod.card_brand,
              customer_id: @paymentmethod.customer_id,
              currency: @paymentmethod.currency
          }
      }, xhr: true
    end

    assert_response :success
  end

  test "should upgrade paymentmethod" do
    @upgrade = paymentmethods(:two)

    get "/paymentmethods/new?upgrade=#{@upgrade.id}"

    token = create_stripe_token(cardno: @upgrade.card_number, exp_month: @upgrade.card_exp_month, exp_year: @upgrade.card_exp_year)

    post paymentmethods_url, params: {
        paymentmethod: {
            token: token.id,
            default: true,
            card_number: @upgrade.card_number,
            card_exp_month: @upgrade.card_exp_month,
            card_exp_year: @upgrade.card_exp_year,
            card_brand: @upgrade.card_brand,
            customer_id: @upgrade.customer_id,
            currency: @upgrade.currency
        }
    }, xhr: true

    assert_match("Turbolinks.clearCache()\nTurbolinks.visit(\"#{root_url}\", {\"action\":\"replace\"})", response.body)
  end

  test "should create paymentmethod from invoice" do
    @upgrade = paymentmethods(:two)
    @invoice = invoices(:three)

    get "/paymentmethods/new?invoice=#{@invoice.id}"

    token = create_stripe_token(cardno: @upgrade.card_number, exp_month: @upgrade.card_exp_month, exp_year: @upgrade.card_exp_year)

    post paymentmethods_url, params: {
        paymentmethod: {
            token: token.id,
            default: true,
            card_number: @upgrade.card_number,
            card_exp_month: @upgrade.card_exp_month,
            card_exp_year: @upgrade.card_exp_year,
            card_brand: @upgrade.card_brand,
            customer_id: @upgrade.customer_id,
            currency: @upgrade.currency
        }
    }, xhr: true

    assert_match("Turbolinks.clearCache()\nTurbolinks.visit(\"#{invoice_url(@invoice)}\", {\"action\":\"replace\"})", response.body)
  end

  test "should show paymentmethod" do
    create_paymentmethod()
    get paymentmethod_url(@paymentmethod)
    assert_response :success
  end

  test "should get edit" do
    create_paymentmethod()
    get edit_paymentmethod_url(@paymentmethod)
    assert_response :success
  end

  test "should update paymentmethod" do
    create_paymentmethod()
    @paymentmethod2 = paymentmethods(:two)

    @paymentmethod.update(default: true,
      card_number: @paymentmethod2.card_number,
      card_exp_month: @paymentmethod2.card_exp_month,
      card_exp_year: @paymentmethod2.card_exp_year,
      card_brand: @paymentmethod2.card_brand,
      customer_id: @paymentmethod2.customer_id,
      currency: @paymentmethod2.currency
    )

    assert_response :success
  end

  test "should destroy paymentmethod" do
    create_paymentmethod()
    assert_difference 'Paymentmethod.count', -1 do
      delete paymentmethod_url(@paymentmethod)
    end

    assert_redirected_to paymentmethods_url
  end
end
