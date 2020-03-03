class EmailViewerController < ApplicationController
  before_action :logged_in_user

  def connect_account
    @emailaccount = current_user.emailaccounts.first
  end

  def view_messages

  end

end
