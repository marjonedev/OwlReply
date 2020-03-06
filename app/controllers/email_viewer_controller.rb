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
    @user = current_user
    if @user.skip_activation or @user.active
      redirect_to root_url, alert: "Your account is already activated."
    end
  end
end
