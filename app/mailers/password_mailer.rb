class PasswordMailer < ActionMailer::Base
  default from: 'info@owlreply.com'

  def verification_reset_email(user)
    @user = user
    mail(to: @user.email, subject: 'Sample Email')
  end
end
