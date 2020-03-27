class AdminController < ApplicationController
  before_action :verify_admin

  def accounts
    @accounts = User.where(:admin => false)
  end

  def emailaccounts
    @emailaccounts =  Emailaccount.left_joins(:user).where(users: {admin: false})
  end

  def replies
    @replies = Reply.all
  end

  def subscribers
    @subscribers = User.joins(:subscription).where('subscriptions.price > 0')
  end

  private
  def verify_admin
    unless current_user.admin
      redirect_to root_url

    end
  end

end
