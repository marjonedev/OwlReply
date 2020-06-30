class InboxController < ApplicationController
  before_action :require_login
  before_action :set_emailaccount
  include GoogleConnector
  include IMAPConnector

  def show
    @messages = []
    @errors = []
    if @emailaccount.authenticated
      if @emailaccount.setupcomplete || @emailaccount.skip_activation
        if @emailaccount.email_provider == "google"
          api = GmailApi.new @emailaccount

          result = api.get_messages(limit: (params[:more] ? 20 : 2), unread: (params[:all] ? false : true))
          messages = result
          @errors.push("No unread emails.") if messages.empty?
          @errors.concat(api.errors) if api.errors
          # We could redirect the user someone based on the error, like back to Google.

          messages.each do |msg|
            date = DateTime.parse(msg['date'])
            formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
            subject = msg['subject']
            from = msg['from']
            thebody = msg['body_text'].to_s.gsub("\r\n", " ")
            thebody = thebody.truncate(80, separator: " ")

            @messages.push({date: formatted_date, subject:subject, body: msg['body'], body_text: thebody, from: from, unread: msg['unread']})
          end
        else

          api = IMAPApi.new @emailaccount
          messages = api.get_messages(limit: (params[:more] ? 20 : 2), unread: (params[:all] ? false : true))
          @errors.push("No unread emails.") if messages.empty?
          @errors.concat(api.errors) if api.errors

          messages.each do |msg|
            next if msg['is_thread']
            date = DateTime.parse(msg['date'])
            formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
            subject = msg['subject']
            from = msg['from']
            thebody = msg['body_text'].to_s.gsub("\r\n", " ")
            thebody = thebody.truncate(80, separator: " ")

            @messages.push({date: formatted_date, subject:subject, body: msg['body'], body_text: thebody, from: from, unread: msg['unread']})
          end
        end
      else
        @errors.push("Email account setup is on progress. You will see your unread messages once the setup has been completed.")
      end
    else
      @errors.push("Email account is still not connected.")
    end

  end


  private

  def set_emailaccount
    @emailaccount = current_user.emailaccounts.find(params[:id])
  end

  def replier_logger
    @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
  end
end
