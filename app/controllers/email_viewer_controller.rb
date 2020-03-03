class EmailViewerController < ApplicationController
  before_action :logged_in_user
  before_action :validate

  def connect_account
    @emailaccount = current_user.emailaccounts.first
  end

  def view_messages
    @emailaccount = current_user.emailaccounts.first
    include GoogleConnector
    api = GmailApi.new @emailaccount


    begin

      messages = api.get_messages()


      if messages.empty?
        replier_logger.error("GOOGLE - Messages are empty.")
        return
      end

      messages.each do |msg|
        date = DateTime.parse(msg['date'])
        formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
        subject = msg['subject']
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

  end

  private
  def replier_logger
    @@replier_logger ||= Logger.new("#{Rails.root}/log/replier.log")
  end

  def validate
    accounts = current_user.emailaccounts

    if accounts.count > 1
      redirect_to root_url
    end


  end
end
