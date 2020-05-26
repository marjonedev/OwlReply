class WizardController < ApplicationController
  before_action :require_login
  before_action :set_emailaccount
  before_action :validate
  include GoogleConnector
  include IMAPConnector

  def connect_account

    unless @emailaccount.setupcomplete
      if @emailaccount.authenticated
        redirect_to "/wizard/2/#{@emailaccount.id}", notice: "Your account is already connected. Preview your messages to finish the process."
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
        next if msg['is_thread']
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
      messages = api.get_messages(limit: (params[:more] ? 20 : 2))
      @errors.concat(api.errors)
      @errors.push("No unread emails.") if messages.empty?

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
