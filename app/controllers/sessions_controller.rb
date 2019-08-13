class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      render json: {
          status: :created,
          logged_in: true,
          user: user
      }
      # redirect_to root_url, notice: "Logged in!"
    else
      flash.now[:alert] = "Username or password is invalid"
      render json: {
          status: 401
      }
      # render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end


end
