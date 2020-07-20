require 'test_helper'

class IgnoredwordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    @ignoredword = ignoredwords(:one)
  end

  test "should create ignoredword via ajax" do
    post ignoredwords_url, params: { ignoredword: { word: "computer" } }, xhr: true
    assert_response :success
  end

  test "should get new" do
    get new_ignoredword_url
    assert_response :success
  end

  test "should get new via ajax" do
    get new_ignoredword_url, xhr: true
    assert_response :success
  end

  test "should destroy ignoredword from ajax" do
    assert_difference('Ignoredword.count', -1) do
      delete ignoredword_url(@ignoredword), xhr: true
    end

    assert_response :success
  end

  test "should ignore via ajax" do
    @emailaccount = emailaccounts(:email1)
    post ignore_ignoredword_url(@emailaccount, ignoredword: {word: "computer"}), xhr: true
    assert_response :success
  end
end
