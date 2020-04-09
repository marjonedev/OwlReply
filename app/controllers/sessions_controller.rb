class SessionsController < ApplicationController
  before_action :set_attempted_user, only: [:create]

  def new
  end

  def create
    if @attempted_user&.can_authenticate_with?(params[:user][:password])
      session[:user_id] = @attempted_user.id
      redirect_to root_url, id: @attempted_user.id
    else
      flash.now[:errormsg] = "Username or password is invalid."
      render "new"
    end
  end

  def create_OLDDELETE
    username = params[:user][:username]
    password = params[:user][:password]

    if (!!username.match(/\A[\w.+-]+@\w+\.\w+\z/))
      users_with_email = User.where(email_address: username)
      if users_with_email.count > 1
        flash.now[:errormsg] = "Please enter your username, not your email."
        render "new"
      else
        user = User.find_by(email_address: username)
        authenticate = User.authenticate(user.username, password)
        if user && authenticate
          session[:user_id] = user.id
          redirect_to root_url, id: user.id
        else
          flash.now[:errormsg] = "Username or password is not valid"
          render "new"
        end
      end
    else
      user = User.find_by(username: username)
      authenticate = User.authenticate(username, password)
      if user && authenticate
        session[:user_id] = user.id
        redirect_to root_url, id: user.id
      else
        flash.now[:errormsg] = "Username or password is invalid"
        render "new"
      end
    end

  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end

  private
  def set_attempted_user
    @attempted_user = nil
    if params[:user][:username].match(/\A[\w.+-]+@\w+\.\w+\z/)
      @attempted_user = (User.where(email_address: params[:user][:username])==1) ? User.find_by(email_address: params[:user][:username]) : nil
    else
      @attempted_user = User.find_by(username: params[:user][:username])
    end
  end

end
