class PasswordsController < ApplicationController

  before_action :validate_token, only: :reset

  def forgot

    respond_to do |format|
      if emailaccount_params[:email_address].blank? # check if email is present
        format.js { render :template => 'passwords/forgot_blank'}
        format.json {render json: {error: 'Email not present'}, status: :not_found}
      else
        user = User.find_by(email_address: emailaccount_params[:email_address]) # if present find user by email

        if user.present?
          user.generate_password_token! #generate pass token
          PasswordMailer.with(user: user).reset_password_email.deliver_now #deliver email
          # format.js { render :template => 'passwords/forgot_success' }
          flash[:successmsg] = "An email with password reset instructions has been sent to your email address."
          format.html {redirect_to login_url}
          format.json {render json: {status: 'ok'}, status: :ok}
        else
          format.js { render :template => 'passwords/forgot_error' }
          format.json {render json: {error: 'Email address not found. Please check and try again.'}, status: :not_found}
        end
      end
    end

  end

  def reset_submit
    token = reset_params[:token].to_s

    if reset_params[:password].length < 8
      return render :template => 'passwords/change_password_error', :locals => { :message => 'Password too short.' }
    elsif reset_params[:password].length > 40
      return render :template => 'passwords/change_password_error', :locals => { :message => 'Password too long.' }
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(reset_params[:password])
        flash[:successmsg] = "Your password has been changed. Try to login with the new password now."
        return redirect_to login_url
      else
        return render :template => 'passwords/change_password_error', :locals => { :message => 'Ops. There is an error. Please try different password.' }
      end
    else
      render :template => 'passwords/change_password_error', :locals => { :message => 'Link not valid or expired. Try generating a new link.'}
    end
  end

  def reset
    @token = params[:token].to_s
  end

  private
    def validate_token
      token = params[:token].to_s

      if token.blank?
        redirect_to forgot_password_url, alert: "Token is not present. Try to request password reset again."
      end

      user = User.find_by(reset_password_token: token)

      if user.present? && user.password_token_valid?
      else
        redirect_to forgot_password_url, alert: "Token is not valid. Try to request password reset again."
      end
    end

    def reset_params
      params
          .require(:user)
          .permit(:email_address, :password, :token)
    end

    def emailaccount_params
      params
          .require(:user)
          .permit(:email_address)
    end
end
