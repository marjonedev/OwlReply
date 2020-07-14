class AdminMailer < ApplicationMailer
  default from: 'OwlReply Notification <notification@owlreply.com>'

  def notification_email
    @message = params[:subject]
    @process = params[:process]
    mail(to: "ceo@owlreply.com,marjone@owlreply.com", subject: "Owlreply Notification: #{@message}")
  end

  def zero_reply_notification_email
    mail(to: "ceo@owlreply.com,marjone@owlreply.com", subject: "Owlreply Notification: Zero Reply Made Today")
  end
end
