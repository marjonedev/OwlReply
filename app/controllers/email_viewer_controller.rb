class EmailViewerController < ApplicationController
  before_action :logged_in_user
  before_action :validate
  include GoogleConnector

  def connect_account

    unless @user.active
      account = @user.emailaccounts.first
      if account.authenticated
        redirect_to email_viewer_step2_url, notice: "Your account is already connected. Preview your messages to finish the process."
      end
    end

    @emailaccount = current_user.emailaccounts.first
  end

  def view_messages
    @emailaccount = current_user.emailaccounts.first

    @messages = []

    if @emailaccount.email_provider == "google"
      api = GmailApi.new @emailaccount

        begin

          messages = api.get_messages(max: 2)

          if messages.empty?
            replier_logger.error("GOOGLE - Messages are empty.")
            return
          end

          messages.each do |msg|
            date = DateTime.parse(msg['date'])
            formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
            subject = msg['subject']
            from = msg['from']
            thebody = msg['body_text'].to_s.gsub("\r\n", " ")
            thebody = thebody.truncate(60)

            @messages.push({date: formatted_date, subject:subject, body: thebody, from: from})
          end

        rescue Google::Apis::AuthorizationError => exception
          replier_logger.error exception.message
          exception.backtrace.each { |line| replier_logger.error line }

          begin
            api.refresh_api!
          rescue RefreshTokenFailureError => error
            replier_logger.error("GOOGLE: #{account.address} - Failed to refresh user token. #{error.to_s}")
            # return []
          end

        rescue Exception => e
          replier_logger.error e.message
          e.backtrace.each { |line| replier_logger.error line }
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
        # reply_used = false
        # data = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
        # msg = Mail.read_from_string data
        #
        # date = DateTime.rfc3339(msg.date.to_s)
        # formatted_date = date.strftime("%a, %b %d, %Y at %I:%M %p")
        #
        # thebody = msg.body.to_s.gsub("\r\n", " ")
        # thebody = thebody.truncate(60)
        envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]

        replier_logger.debug "==============1212123213123============================="
        replier_logger.debug "#{envelope.from[0].name}: \t#{envelope.subject}"

      end


    end

  end

  def done

  end

  def skip_activation
    respond_to do |format|
      current_user.update_attribute(:skip_activation, true)
      format.html { redirect_to root_url, notice: 'Skipped! You connect your account manually.' }
    end
  end

  def activate
    respond_to do |format|
      current_user.update_attribute(:active, true)
      format.html { redirect_to root_url, notice: 'Congratulations! Your account is now activated.' }
    end
  end

  private
  def replier_logger
    @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
  end

  def validate
    #skip if account more than 1

    @user = current_user

    if @user.emaiaccounts.count > 1
      redirect_to root_url
    end

    if @user.skip_activation or @user.active
      redirect_to root_url, alert: "Your account is already activated."
    end
  end
end
