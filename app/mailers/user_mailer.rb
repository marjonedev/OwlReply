class UserMailer < ActionMailer::Base
  default from: 'OwlReply <ceo@owlreply.com>'

  def welcome_email
    @user = params[:user]
    @url  = 'https://owlreply.com/login'
    mail(to: @user.email_address, subject: "You're hooting with OwlReply now.")
  end

  def how_to_email
    @user = params[:user]
    @url  = 'https://owlreply.com/login'
    mail(to: @user.email_address, subject: "How to use OwlReply.")
  end

  def informational_email
    @user = params[:user]
    @url  = 'https://owlreply.com/login'
    mail(to: @user.email_address, subject: "OwlReply's got your automation covered.")
  end

end