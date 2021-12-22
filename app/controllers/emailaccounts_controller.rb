require 'googleauth'
require 'json'

class EmailaccountsController < ApplicationController
  include ActionView::Helpers::DateHelper
  include EmailaccountsHelper
  include GoogleConnector
  before_action :require_login
  before_action :set_emailaccount, only: [:show, :edit, :update, :destroy, :emails, :check_again, :status, :connect, :remove, :revoke_account_access, :authenticate_imap, :google_redirect, :reply, :get_keywords, :go_to_authorization]

  # GET /emailaccounts
  # GET /emailaccounts.json
  def index
    @emailaccounts = current_user.emailaccounts
  end

  # GET /emailaccounts/1
  # GET /emailaccounts/1.json
  def show
    @replies = @emailaccount.replies.order("created_at DESC")
  end

  # GET /emailaccounts/new
  def new
    @emailaccount = Emailaccount.new
  end

  # GET /emailaccounts/1/edit
  def edit
  end

  def emails
    @messages = @emailaccount.get_email_messages(limit: (params[:more] ? 20 : 10), unread: false)

  end

  # POST /emailaccounts
  # POST /emailaccounts.json
  def create
    @emailaccount = current_user.emailaccounts.new(emailaccount_params)

    respond_to do |format|
      if @emailaccount.save
        format.html { redirect_to "/wizard/1/#{@emailaccount.id}", notice: 'Email account was successfully created.' }
        format.json { render :show, status: :created, location: @emailaccount }
        # format.js {  }
      else
        format.js { render :new }
        format.html { render :new }
        format.json { render json: @emailaccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /emailaccounts/1
  # PATCH/PUT /emailaccounts/1.json
  def update
    respond_to do |format|
      if @emailaccount.update(emailaccount_params)
        format.html { redirect_to @emailaccount, notice: 'Email account was successfully updated.' }
        format.json { render :show, status: :ok, location: @emailaccount }
        format.js { redirect_to @emailaccount, notice: 'Email account was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @emailaccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /emailaccounts/1
  # DELETE /emailaccounts/1.json
  def destroy
    unless is_main_account(@emailaccount)
      @emailaccount.destroy
      respond_to do |format|
        format.html { redirect_to emailaccounts_url, notice: 'Email Account was successfully removed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to emailaccount_url(@emailaccount), notice: 'Cannot remove main email account' }
        format.json { head :no_content }
      end
    end

  end

  def remove
    @remove = is_main_account(@emailaccount) ? false : true
    respond_to do |format|
        format.js {}
    end
  end

  def check_again
    @emailaccount.update_attribute(:last_checked, nil)

    EmailaccountChannel.broadcast_to(@emailaccount, {last_checked: ""})

    respond_to do |format|
      format.js {}
    end
  end

  def status
    last_checked = nil

    if @emailaccount.error
      last_checked = "Last error: #{@emailaccount.error}"
    end
    unless @emailaccount.last_checked.nil?
      last_checked = "Last checked: #{time_ago_in_words @emailaccount.last_checked} ago"
    end

    respond_to do |format|
      # format.html
      format.json {render json: {data:last_checked}}
    end
  end

  def authenticate_imap

    require 'net/imap'

    ssl = connect_params[:imap_ssl] ? {ssl_version: :TLSv1_2} : false
    # ssl = connect_params[:imap_ssl] ? true : false
    port = connect_params[:imap_port] ? connect_params[:imap_port]  : 993
    host = connect_params[:imap_host].to_s.empty? ? connect_params[:address].to_s.split("@").last : connect_params[:imap_host]
    address = connect_params[:address]
    password = connect_params[:password]

    begin
      imap = Net::IMAP.new(host, ssl: ssl, port: port)
      imap.authenticate('PLAIN', address, password)
      respond_to do |format|
        format.json {render json: {success: true}}
      end
    rescue
      respond_to do |format|
        format.json {render json: {success: false, message: "#{$!.to_s}"}}
      end
    end

  end

  def go_to_authorization
    if @emailaccount.email_provider == 'google'
      redirect_to google_redirect_emailaccount_url(@emailaccount)
    else
      redirect_to "/wizard/2/#{@emailaccount.id}"
    end
  end

  def connect
    if connect_params[:email_provider] == "google"

      redirect_to google_redirect_emailaccount_url(@emailaccount)

    else
      respond_to do |format|
        if @emailaccount.update(connect_params)
          @emailaccount.update(authenticated: true)
          format.html { redirect_to (@emailaccount.setupcomplete ? @emailaccount : "/wizard/2/#{@emailaccount.id}"), notice: "#{@emailaccount.address} successfully authenticated." }
          # format.json { render :show, status: :ok, location: @emailaccount }
          # format.js { redirect_to @emailaccount, notice: "Email account was successfully updated." }
        else
          # format.html { render :edit }
          format.json { render json: @emailaccount.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def google_redirect
    google = GoogleConnector::GmailApi.new(@emailaccount)
    redirect_to google.get_authorization_url(emailaccounts_google_callback_url)
  end

  def google_callback

    state = params[:state]
    state = JSON.parse(state)
    @emailaccount = Emailaccount.find(state['emailaccount_id'])

    api_client_id = Rails.application.credentials.google_api_client_id
    api_client_secret = Rails.application.credentials.google_client_secret

    credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: api_client_id,
        client_secret: api_client_secret,
        scope: [Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
                Google::Apis::GmailV1::AUTH_GMAIL_MODIFY,
                Google::Apis::GmailV1::AUTH_GMAIL_COMPOSE], # enter the scope for a service whichever you want to use
        redirect_uri: emailaccounts_google_callback_url,
        additional_parameters: {
            access_type: "offline",
            prompt: "consent"
        })

    credentials.code = params[:code]
    response = credentials.fetch_access_token!

    expires_in = Time.now.to_i + response['expires_in']

    @emailaccount.update({google_access_token: response["access_token"],
                                          google_expires_in: expires_in,
                                          google_refresh_token: response["refresh_token"],
                                          authenticated: 1,
                                          email_provider: 'google'})
    @emailaccount.user.send_first_test_email

    if !@emailaccount.setupcomplete
      redirect_to "/wizard/2/#{@emailaccount.id}", notice: @emailaccount.address + " successfully authenticated"
    else
      redirect_to url_for(action: 'show', id: @emailaccount.id), notice: @emailaccount.address + " successfully authenticated"
    end


  end

  def revoke_account_access

    if @emailaccount.email_provider == "google"
      respond_to do |format|
        api = GmailApi.new @emailaccount

        if api.revoke_access
          format.html { redirect_to @emailaccount, notice: 'Account access has been revoked.' }
          format.json { render :show, status: :ok, location: @emailaccount }
        else
          format.html { redirect_to edit_emailaccount_path(@emailaccount), alert: 'Account has problem revoking access.' }
          format.json { render json: @emailaccount.errors, status: :unprocessable_entity }
        end
      end
    elsif @emailaccount.email_provider == "other"
      @emailaccount.update(authenticated: false)
      respond_to do |format|
        format.html { redirect_to edit_emailaccount_path(@emailaccount), alert: 'Account access has been revoked.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_emailaccount_path(@emailaccount), alert: 'Something doesn\'t seem right.' }
      end
    end

  end

  def reply
    @keyword = params[:keyword]
    @message_id = params[:message]
    # @keywords = @emailaccount.replies.select{|reply|(!(reply.keywords.split(',') & sug).empty?) rescue nil}
    @replies = @emailaccount.replies.select{|e| e.keywords.split(',').include?(@keyword) rescue nil }

    respond_to do |format|
      format.js
    end
  end

  def get_keywords
    sug = params[:suggested]
    sug = sug.split(',')
    res = []
    sug.each do |word|
      replies = @emailaccount.replies.select{|e| e.keywords.split(',').include?(word) rescue nil }
      if replies.empty?
        res.push(word)
      end
    end

    res = sug.select{|word| @emailaccount.replies.select{|e| e.keywords.split(',').include?(word) rescue nil }.empty? }

    render json: { keywords: res }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_emailaccount
      @emailaccount = current_user.emailaccounts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def emailaccount_params
      params
          .require(:emailaccount)
          .permit(:address, :password, :encrypted_password, :encryption_key, :template)
    end

    def connect_params
      params
          .require(:emailaccount)
          .permit(:email_provider, :address, :password, :imap_host, :imap_port, :imap_ssl, :redirect_to)
    end
end
