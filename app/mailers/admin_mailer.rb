class AdminMailer < ApplicationMailer
  default from: 'OwlReply Notification <notification@owlreply.com>'

  def notification_email
    @message = params[:subject]
    @process = params[:process]
    mail(to: "ceo@owlreply.com,marjone@owlreply.com", subject: "Owlreply Notification: #{@message}")
  end
end
