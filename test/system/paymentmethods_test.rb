require "application_system_test_case"

class PaymentmethodsTest < ApplicationSystemTestCase
  setup do
    @paymentmethod = paymentmethods(:one)
  end

  test "visiting the index" do
    visit paymentmethods_url
    assert_selector "h1", text: "Paymentmethods"
  end

  test "creating a Paymentmethod" do
    visit paymentmethods_url
    click_on "New Paymentmethod"

    fill_in "Card exp date", with: @paymentmethod.card_exp_date
    fill_in "Card name", with: @paymentmethod.card_name
    fill_in "Card type", with: @paymentmethod.card_type
    fill_in "Customer", with: @paymentmethod.customer_id
    fill_in "Method", with: @paymentmethod.method
    fill_in "User", with: @paymentmethod.user_id
    click_on "Create Paymentmethod"

    assert_text "Paymentmethod was successfully created"
    click_on "Back"
  end

  test "updating a Paymentmethod" do
    visit paymentmethods_url
    click_on "Edit", match: :first

    fill_in "Card exp date", with: @paymentmethod.card_exp_date
    fill_in "Card name", with: @paymentmethod.card_name
    fill_in "Card type", with: @paymentmethod.card_type
    fill_in "Customer", with: @paymentmethod.customer_id
    fill_in "Method", with: @paymentmethod.method
    fill_in "User", with: @paymentmethod.user_id
    click_on "Update Paymentmethod"

    assert_text "Paymentmethod was successfully updated"
    click_on "Back"
  end

  test "destroying a Paymentmethod" do
    visit paymentmethods_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Paymentmethod was successfully destroyed"
  end
end
