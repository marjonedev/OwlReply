require 'test_helper'

class RepliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_everything_necessary!
    create_emailaccount
    @reply = replies(:one)
  end

  test "should get index" do
    get emailaccount_url(@emailaccount) #since the replies index is under emailaccount template
    assert_response :success
  end

  test "should get new" do
    get new_emailaccount_reply_url(@emailaccount)
    assert_response :success
  end

  # test "should create reply" do
  #   assert_difference('Reply.count') do
  #     post replies_url, params: { reply: { body: @reply.body, catchcall: @reply.catchcall, keywords: @reply.keywords, negative_keywords: @reply.negative_keywords } }
  #   end
  #
  #   assert_redirected_to reply_url(Reply.last)
  # end
  #
  # test "should show reply" do
  #   get reply_url(@reply)
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get edit_reply_url(@reply)
  #   assert_response :success
  # end
  #
  # test "should update reply" do
  #   patch reply_url(@reply), params: { reply: { body: @reply.body, catchcall: @reply.catchcall, keywords: @reply.keywords, negative_keywords: @reply.negative_keywords } }
  #   assert_redirected_to reply_url(@reply)
  # end
  #
  # test "should destroy reply" do
  #   assert_difference('Reply.count', -1) do
  #     delete reply_url(@reply)
  #   end
  #
  #   assert_redirected_to replies_url
  # end
end
