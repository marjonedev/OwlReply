class PasswordMailer < ActionMailer::Base
  default from: 'noreply@owlreply.com'

  def reset_password_email
    @user = params[:user]
    @url = "#{Rails.application.config.base_url"
    @token_url = "#{@url}/password/reset?token=#{@user.reset_password_token}"
    mail(to: @user.email_address, subject: 'Reset Your Password')
  end
end
