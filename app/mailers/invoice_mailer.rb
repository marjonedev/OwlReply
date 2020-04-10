class InvoiceMailer < ApplicationMailer
  default from: 'ceo@owlreply.com'
  layout 'invoice_mailer'

  def invoice_created
    @user = params[:user]
    @invoice = params[:invoice]
    @url  = "#{Rails.application.config.base_url}/invoices/#{@invoice.id}"
    mail(to: @user.email_address, subject: "Invoice #{@invoice.number} from OwlReply")
  end

  def invoice_failed
    @user = params[:user]
    @invoice = params[:invoice]
    @url  = "#{Rails.application.config.base_url}/invoices/#{@invoice.id}"
    mail(to: @user.email_address, subject: "Payment Failed on Invoice #{@invoice.number}")
  end

end
