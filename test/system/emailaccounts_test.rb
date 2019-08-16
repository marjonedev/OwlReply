require "application_system_test_case"

class EmailaccountsTest < ApplicationSystemTestCase
  setup do
    @emailaccount = emailaccounts(:one)
  end

  test "visiting the index" do
    visit emailaccounts_url
    assert_selector "h1", text: "Emailaccounts"
  end

  test "creating a Emailaccount" do
    visit emailaccounts_url
    click_on "New Emailaccount"

    fill_in "Address", with: @emailaccount.address
    fill_in "Encrypted password", with: @emailaccount.encrypted_password
    fill_in "Encryption key", with: @emailaccount.encryption_key
    fill_in "Password", with: @emailaccount.password
    fill_in "User", with: @emailaccount.user_id
    click_on "Create Emailaccount"

    assert_text "Emailaccount was successfully created"
    click_on "Back"
  end

  test "updating a Emailaccount" do
    visit emailaccounts_url
    click_on "Edit", match: :first

    fill_in "Address", with: @emailaccount.address
    fill_in "Encrypted password", with: @emailaccount.encrypted_password
    fill_in "Encryption key", with: @emailaccount.encryption_key
    fill_in "Password", with: @emailaccount.password
    fill_in "User", with: @emailaccount.user_id
    click_on "Update Emailaccount"

    assert_text "Emailaccount was successfully updated"
    click_on "Back"
  end

  test "destroying a Emailaccount" do
    visit emailaccounts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Emailaccount was successfully destroyed"
  end
end
