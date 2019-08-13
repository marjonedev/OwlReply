class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:user][:username])
    if user && user.authenticate(params[:user][:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now[:alert] = "Username or password is invalid"
      # flash.now[:user] = "username: " + params[:username] + ", password: " + params[:password]
      # flash.now[:user_find] = user
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end


end
