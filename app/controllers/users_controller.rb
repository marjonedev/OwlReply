class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    if !logged_in?
      redirect_to login_url
    else
      @users = User.all
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if !logged_in?
      redirect_to login_url
    else
      unless current_user.id == @user.id
        not_found
      end

      @paymentmethods = current_user.paymentmethods
    end

  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        @user.send_welcome_email
        @user.send_how_to_email
        session[:user_id] = @user.id # Make sure the user is logged in after signing in!
        session[:new_sign_up] = true
        # format.html { redirect_to @user.emailaccounts.first }
        format.html { redirect_to "/viewer/step1" }
        format.json { render :show, status: :created, location: @user, color: 'valid' }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity, color: 'invalid' }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Your changes was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email_address, :password, :referer)
    end
end

