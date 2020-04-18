require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    @transaction = transactions(:one)
    @invoice = invoices(:one)
  end

  test "should get index" do
    get transactions_url
    assert_response :success
  end

  test "should get new" do
    get new_transaction_url
    assert_response :success
  end

  test "should create transaction" do

    assert_difference('Transaction.count') do
      post transactions_url, params: { transaction: { amount: @transaction.amount, payment_provider: @transaction.payment_provider, reference: @transaction.reference, reversed: @transaction.reversed, timestamp: @transaction.timestamp, user_id: @user.id, invoice_id: @invoice.id} }
    end

    assert_redirected_to transaction_url(Transaction.last)
  end

  test "should show transaction" do
    get transaction_url(@transaction)
    assert_response :success
  end

  test "should get edit" do
    get edit_transaction_url(@transaction)
    assert_response :success
  end

  test "should update transaction" do
    patch transaction_url(@transaction), params: { transaction: { amount: @transaction.amount, payment_provider: @transaction.payment_provider, reference: @transaction.reference, reversed: @transaction.reversed, timestamp: @transaction.timestamp, user_id: @user.id, invoice_id:  @invoice.id} }
    assert_redirected_to transaction_url(@transaction)
  end

  test "should destroy transaction" do
    assert_difference('Transaction.count', -1) do
      delete transaction_url(@transaction)
    end

    assert_redirected_to transactions_url
  end
end
