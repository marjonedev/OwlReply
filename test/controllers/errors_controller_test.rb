require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get "/404"
    assert_response 404
  end

  test "should get unacceptable" do
    get "/422"
    assert_response 422
  end

  test "should get internal_error" do
    get "/500"
    assert_response 500
  end

end
