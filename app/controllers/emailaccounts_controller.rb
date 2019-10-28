class EmailaccountsController < ApplicationController
  include ActionView::Helpers::DateHelper
  include EmailaccountsHelper
  before_action :logged_in_user
  before_action :set_emailaccount, only: [:show, :edit, :update, :destroy, :check_again, :status, :connect, :remove]

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
    @emailaccount.destroy
    respond_to do |format|
      format.html { redirect_to emailaccounts_url, notice: 'Email Account was successfully removed.' }
      format.json { head :no_content }
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
    respond_to do |format|
      format.js {}
    end
  end

  def status
    last_checked = nil

    if @emailaccount.error
      last_checked = "Last error: #{obj.error}"
    end
    unless @emailaccount.last_checked.nil?
      last_checked = "Last checked: #{time_ago_in_words @emailaccount.last_checked} ago"
    end

    respond_to do |format|
      format.html
      format.json {render json: {data:last_checked}}
    end
  end

  def connect
    if(connect_params[:email_provider] == 'google')

      session[:emailaccount_id] = @emailaccount.id
      redirect_to emailaccounts_google_redirect_url

    else
      respond_to do |format|
        if @emailaccount.update(connect_params)
          # format.html { redirect_to @emailaccount, notice: 'Email account was successfully updated.' }
          # format.json { render :show, status: :ok, location: @emailaccount }
          format.js { redirect_to @emailaccount, notice: 'Email account was successfully updated.' }
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
                  scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
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

=begin
  todo:
    1. access_token and expiry date to database
    2. save email_provider = google
    3. set authenticated = true
=end

    emailaccount_id = session[:emailaccount_id]
    session.delete(:emailaccount_id)

    emailaccount = Emailaccount.where(id: emailaccount_id).first

    expires_in = Time.now.to_i + response['expires_in']

    emailaccount.update(google_access_token: response['access_token'],
                        google_expires_in: expires_in,
                        google_refresh_token: response['refresh_token'],
                        authenticated: true,
                        email_provider: 'google')

    redirect_to url_for(action: 'show', id: emailaccount_id), notice: emailaccount.address + " successfully authenticated"

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
          .permit(:email_provider, :smtp_host, :smtp_email, :smtp_password, :smtp_port, :smtp_ssl)
    end
end
