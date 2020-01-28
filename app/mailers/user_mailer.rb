class UserMailer < ActionMailer::Base
  default from: 'OwlReply <ceo@owlreply.com>'

  def welcome_email
    @user = params[:user]
    @url  = 'https://owlreply.com/login'
    mail(to: @user.email_address, subject: "You're hooting with OwlReply now.")
  end

end