require 'test_helper'

class EmailaccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @emailaccount = Emailaccount.first
  end
  test "creates an api object" do
    GoogleConnector::GmailApi.new(@emailaccount)
  end
end
