require 'test_helper'

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    @invoice = invoices(:one)
  end

  teardown do
    @invoice = nil
    Invoice.destroy_all
  end

  test "should get index" do
    get invoices_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_url
    assert_response :success
  end

  test "should create invoice" do
    assert_difference('Invoice.count') do
      create_user_invoice
    end

    assert_response :success
  end

  test "should show invoice" do
    create_user_invoice
    get invoice_url(Invoice.last)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_url(@invoice)
    assert_response :success
  end

  test "should update invoice" do
    create_user_invoice
    patch invoice_url(@user.invoices.last), params: { invoice: { amount: @invoice.amount, amount_paid: @invoice.amount_paid, date_paid: @invoice.date_paid, transaction_id: @invoice.transaction_id, user_id: @invoice.user_id } }
    assert_redirected_to invoices_url
  end

  test "should destroy invoice" do
    create_user_invoice
    assert_difference('Invoice.count', -1) do
      @user.invoices.last.destroy
    end

    assert_response :success
  end
end
