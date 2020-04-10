class EmailaccountMailer < ActionMailer::Base
  default from: 'ceo@owlreply.com'

  def suggestion_email
    @user = params[:user]
    @url  = "#{Rails.application.config.base_url}/login"
    mail(to: @user.email, subject: "Suggested keyword to automate.")
  end

  def connection_email
    @user = params[:user]
    @url  = "#{Rails.application.config.base_url}/login"
    mail(to: @user.email, subject: "You still have to connect your email account.")
  end

end