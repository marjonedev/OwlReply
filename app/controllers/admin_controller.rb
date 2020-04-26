class AdminController < ApplicationController
  before_action :verify_admin

  def accounts
    @accounts = User.where(admin: false)
  end

  def accounts_emailaccounts
    @account = User.find(params[:id])
    @emailaccounts = @account.emailaccounts
    render action: 'emailaccounts'
  end

  def emailaccounts
    @emailaccounts =  Emailaccount.left_joins(:user).where(users: {admin: false}).order(created_at: :DESC)
  end

  def emailaccount
    @emailaccount = Emailaccount.find(params[:id])
  end

  def replies
    @replies = Reply.all
  end

  def subscribers
    @subscribers = User.joins(:subscription).where('subscriptions.price > 0')
  end

  def late_invoices
    @invoices = Invoice.where('(amount_paid IS NULL OR amount_paid = "") OR (date_paid IS NULL OR date_paid = "")')
  end

  def show_invoice
    @invoice = Invoice.find(params[:id])
  end

  private
  def verify_admin
    unless current_user.admin
      redirect_to root_url
    end
  end

end
