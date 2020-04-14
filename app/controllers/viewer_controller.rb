class ViewerController < ApplicationController
  before_action :require_login
  before_action :set_emailaccount
  before_action :validate
  include GoogleConnector

  def connect_account

    unless @emailaccount.setupcomplete
      if @emailaccount.authenticated
        redirect_to "/viewer/step2/#{@emailaccount.id}", notice: "Your account is already connected. Preview your messages to finish the process."
      end
    end

  end

  def view_messages
    @messages = []
    @errors = []
    if @emailaccount.email_provider == "google"
      api = GmailApi.new @emailaccount
      messages = api.get_messages(limit: (params[:more] ? 20 : 2))
      @errors.concat(api.errors)
      @errors.push("No unread emails.") if messages.empty?

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

      # Here is the imap process

      require 'net/imap'
      require 'mail'
      require 'date'

      ssl = @emailaccount.imap_ssl ? {ssl_version: :TLSv1_2} : false
      port = @emailaccount.imap_port ? @emailaccount.imap_port : 993
      host = @emailaccount.imap_host.to_s.empty? ? @emailaccount.address.to_s.split("@").last : @emailaccount.imap_host

      imap = Net::IMAP.new(host, ssl: ssl, port: port )
      imap.login(@emailaccount.address, @emailaccount.password)

      folders =  imap.list('', "*")

      inbox = folders.any? { |h| h.name.to_s.downcase == 'inbox' } ? folders.find { |h| h.name.to_s.downcase == 'inbox' }.name : 'INBOX'

      imap.examine(inbox)

      start_date = 1.week.ago.strftime("%d-%b-%Y")

      showMessages = 5

      imap.search(["UNSEEN", "SINCE", start_date]).each do |message_id|
        if showMessages < 1
          break
        end

        email = imap.fetch(message_id, "RFC822")[0].attr["RFC822"]

        msg = Mail.read_from_string email
        from = msg[:from].display_names.first

        mid = msg.body.to_s[0, 30]
        body = msg.body.to_s.split(mid)
        thebody = ""

        body.each do |m|
          if m.include?("Content-Type: text/plain; charset=\"UTF-8\"")
            text = m.gsub("\n\n", "")
            text = text.gsub("\nContent-Type: text/plain; charset=\"UTF-8\"", "")
            thebody << text
            break
          end
        end

        thebody = thebody.to_s.gsub("\r\n", " ")
        thebody = thebody.truncate(80, separator: " ")

        date = DateTime.parse(msg.date.to_s)
        formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
        subject = msg.subject
        from = from

        @messages.push({date: formatted_date, subject:subject, body: thebody, from: from})

        showMessages -= 1

      end

    end

  end

  def done
    keywords = (params[:keywords] || '').split(",")
    for keyword in keywords
      @emailaccount.replies.create(keywords: keyword, search: "Subject and Body", body: "")
    end
  end

  def skip_activation
    respond_to do |format|
      @emailaccount.update_attribute(:skip_activation, true)
      format.html { redirect_to root_url, notice: 'Skipped! You connect your account manually.' }
    end
  end

  def activate
    respond_to do |format|
      # current_user.update_attribute(:active, true)
      if @emailaccount.update_attribute(:setupcomplete,true) # This is BAD.
        format.html { redirect_to root_url, notice: 'Congratulations! Your account is now activated.', :status => :moved_permanently }
      end
    end
  end

  private
  def replier_logger
    @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
  end

  def validate
    if @emailaccount.skip_activation
      redirect_to root_url
    end

    if @emailaccount.setupcomplete
      redirect_to root_url, alert: "Your account is already activated."
    end
  end

  def set_emailaccount
    @emailaccount = current_user.emailaccounts.first
    @emailaccount = current_user.emailaccounts.find(params[:id]) if params[:id]
  end
end
