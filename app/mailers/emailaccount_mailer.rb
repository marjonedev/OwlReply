class EmailaccountMailer < ActionMailer::Base
  default from: 'ceo@owlreply.com'

  def suggestion_email
    @user = params[:user]
    @url  = 'https://owlreply.com/login'
    mail(to: @user.email, subject: "Suggested keyword to automate.")
  end

  def connection_email
    @user = params[:user]
    @url  = 'https://owlreply.com/login'
    mail(to: @user.email, subject: "You still have to connect your email account.")
  end

end