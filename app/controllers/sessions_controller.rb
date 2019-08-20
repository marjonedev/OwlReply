class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:user][:username])
    authenticate = User.authenticate(params[:user][:username], params[:user][:password])
    if user && authenticate
      e
      redirect_to controller: "users", action: "show", id: user.id
    else
      flash.now[:errormsg] = "Username or password is invalid"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end


end
