class EmailaccountMailer < ActionMailer::Base
  default from: 'OwlReply <ceo@owlreply.com>'

  def suggestion_email
    @emailaccount = params[:emailaccount]
    @url  = "#{Rails.application.config.base_url}"
    @words = Wordcount.most_frequent(@emailaccount).pluck(:word)
    mail(to: @emailaccount.address, subject: "Suggested keyword to automate.")
  end

  def connection_email
    @user = params[:user]
    @url  = "#{Rails.application.config.base_url}/login"
    mail(to: @user.email, subject: "You still have to connect your email account.")
  end

end