class InboxController < ApplicationController
  before_action :require_login
  before_action :set_emailaccount
  include GoogleConnector
  include IMAPConnector

  def show
    @messages = []
    @errors = []
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

      # # Here is the imap process
      #
      # require 'net/imap'
      # require 'mail'
      # require 'date'
      #
      # ssl = @emailaccount.imap_ssl ? {ssl_version: :TLSv1_2} : false
      # port = @emailaccount.imap_port ? @emailaccount.imap_port : 993
      # host = @emailaccount.imap_host.to_s.empty? ? @emailaccount.address.to_s.split("@").last : @emailaccount.imap_host
      #
      # imap = Net::IMAP.new(host, ssl: ssl, port: port )
      # imap.login(@emailaccount.address, @emailaccount.password)
      #
      # folders =  imap.list('', "*")
      #
      # inbox = folders.any? { |h| h.name.to_s.downcase == 'inbox' } ? folders.find { |h| h.name.to_s.downcase == 'inbox' }.name : 'INBOX'
      #
      # imap.examine(inbox)
      #
      # start_date = 1.week.ago.strftime("%d-%b-%Y")
      #
      # showMessages = 5
      #
      # imap.search(["UNSEEN", "SINCE", start_date]).each do |message_id|
      #   if showMessages < 1
      #     break
      #   end
      #
      #   email = imap.fetch(message_id, "RFC822")[0].attr["RFC822"]
      #
      #   msg = Mail.read_from_string email
      #   from = msg[:from].display_names.first
      #
      #   mid = msg.body.to_s[0, 30]
      #   body = msg.body.to_s.split(mid)
      #   thebody = ""
      #
      #   body.each do |m|
      #     if m.include?("Content-Type: text/plain; charset=\"UTF-8\"")
      #       text = m.gsub("\n\n", "")
      #       text = text.gsub("\nContent-Type: text/plain; charset=\"UTF-8\"", "")
      #       thebody << text
      #       break
      #     end
      #   end
      #
      #   thebody = thebody.to_s.gsub("\r\n", " ")
      #   thebody = thebody.truncate(80, separator: " ")
      #
      #   date = DateTime.parse(msg.date.to_s)
      #   formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
      #   subject = msg.subject
      #   from = from
      #
      #   @messages.push({date: formatted_date, subject:subject, body: thebody, from: from})
      #
      #   showMessages -= 1
      #
      # end

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
