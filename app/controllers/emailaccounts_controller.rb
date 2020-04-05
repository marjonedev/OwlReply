class EmailaccountsController < ApplicationController
  include ActionView::Helpers::DateHelper
  include EmailaccountsHelper
  include GoogleConnector
  before_action :require_login
  before_action :set_emailaccount, only: [:show, :edit, :update, :destroy, :check_again, :status, :connect, :remove, :revoke_account_access, :authenticate_imap]

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

  # POST /emailaccounts
  # POST /emailaccounts.json
  def create
    @emailaccount = current_user.emailaccounts.new(emailaccount_params)

    respond_to do |format|
      if @emailaccount.save
        format.html { redirect_to @emailaccount, notice: 'Email account was successfully created.' }
        format.json { render :show, status: :created, location: @emailaccount }
        format.js {  }
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
      format.html
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

  def connect
    if connect_params[:email_provider] == "google"

      session["emailaccount_id_#{current_user.id}"] = @emailaccount.id
      session["redirect_to_#{current_user.id}"] = connect_params[:redirect_to] ? connect_params[:redirect_to] : false
      redirect_to emailaccounts_google_redirect_url

    else
      respond_to do |format|
        if @emailaccount.update(connect_params)
          @emailaccount.update(authenticated: true)
          # redirect_to @emailaccount, notice: "#{@emailaccount.address} successfully authenticated."
          redirect_to = connect_params[:redirect_to] ? connect_params[:redirect_to] : @emailaccount
          format.html { redirect_to redirect_to, notice: "#{@emailaccount.address} successfully authenticated." }
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
    api_client_id = Rails.application.credentials.google_api_client_id
    api_client_secret = Rails.application.credentials.google_client_secret

    client = Signet::OAuth2::Client.new({
                  client_id: api_client_id,
                  client_secret: api_client_secret,
                  authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                  # scope: %w(https://mail.google.com/ https://www.googleapis.com/auth/gmail.compose https://www.googleapis.com/auth/gmail.modify), # enter the scope for a service whichever you want to use
                  scope: [Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
                          Google::Apis::GmailV1::AUTH_GMAIL_MODIFY,
                          Google::Apis::GmailV1::AUTH_GMAIL_COMPOSE],
                  redirect_uri: emailaccounts_google_callback_url
              })

    redirect_to client.authorization_uri.to_s
  end

  def google_callback
    api_client_id = Rails.application.credentials.google_api_client_id
    api_client_secret = Rails.application.credentials.google_client_secret

    client = Signet::OAuth2::Client.new({
                client_id: api_client_id,
                client_secret: api_client_secret,
                token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                redirect_uri: emailaccounts_google_callback_url,
                code: params[:code]
            })

    response = client.fetch_access_token!

    session[:access_token] = response['access_token']

    emailaccount_id = session["emailaccount_id_#{current_user.id}"]
    session.delete("emailaccount_id_#{current_user.id}")


    expires_in = Time.now.to_i + response['expires_in']



    @emailaccount = Emailaccount.update(emailaccount_id, {google_access_token: response["access_token"],
                                          google_expires_in: expires_in,
                                          google_refresh_token: response["refresh_token"],
                                          authenticated: 1,
                                          email_provider: 'google'})


    redirect_path = session["redirect_to_#{current_user.id}"]
    session.delete("redirect_to_#{current_user.id}")

    if redirect_path
      redirect_to redirect_path, notice: @emailaccount.address + " successfully authenticated"
    else
      redirect_to url_for(action: 'show', id: emailaccount_id), notice: @emailaccount.address + " successfully authenticated"
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
