class UserMailer < ActionMailer::Base
  default from: 'OwlReply <ceo@owlreply.com>'

  def welcome_email
    @user = params[:user]
    @url  = "#{Rails.application.config.base_url}/login"
    mail(to: @user.email_address, subject: "You're hooting with OwlReply now.")
  end

  def how_to_email
    @user = params[:user]
    @url  = "#{Rails.application.config.base_url}/login"
    mail(to: @user.email_address, subject: "How to use OwlReply.")
  end

  def first_test_email
    @user = params[:user]
    @url  = "#{Rails.application.config.base_url}/login"
    mail(to: @user.email_address, subject: "OwlReply - Customer email example.")
  end

  def informational_email
    @user = params[:user]
    @url = "#{Rails.application.config.base_url}"
    mail(to: @user.email_address, subject: "OwlReply's guides to email automation.")
  end

  def feedback
    @user = params[:user]
    mail(to: @user.email_address, subject: "How are you liking OwlReply?")
  end

end