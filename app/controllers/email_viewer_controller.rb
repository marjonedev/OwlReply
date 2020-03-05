class EmailViewerController < ApplicationController
  before_action :logged_in_user
  before_action :validate
  include GoogleConnector

  def connect_account
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

    end

  end

  def done

  end

  private
  def replier_logger
    @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
  end

  def validate
    # if user.active=0
      # connected account should redirect to step 2
    # if user.active=1, redirect to root

    accounts = current_user.emailaccounts

    if accounts.count > 1
      redirect_to root_url
    end

  end
end
