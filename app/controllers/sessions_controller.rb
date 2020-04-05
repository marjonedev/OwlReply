class SessionsController < ApplicationController
  def new
  end

  def create
    username = params[:user][:username]
    password = params[:user][:password]
    if (!!username.match(/\A[\w.+-]+@\w+\.\w+\z/))
      users_with_email = User.where(email_address: username)
      if users_with_email.count > 1
        flash.now[:errormsg] = "Please enter your username, not your email."
        render "new"
      else
        user = User.find_by(email_address: username)
        authenticate = User.authenticate(username, password)
        if user && authenticate
          session[:user_id] = user.id
          redirect_to root_url, id: user.id
        else
          flash.now[:errormsg] = "Username or password is invalid"
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


end
