class PasswordsController < ApplicationController

  before_action :validate_token, only: :reset

  def forgot

    respond_to do |format|
      if params[:email_address].blank? # check if email is present
        format.js { render :template => 'passwords/forgot_blank'}
        format.json {render json: {error: 'Email not present'}, status: :not_found}
      else
        user = User.find_by(email_address: params[:email_address]) # if present find user by email

        if user.present?
          user.generate_password_token! #generate pass token
          # send email function here
          format.js { render :template => 'passwords/forgot_success' }
          format.json {render json: {status: 'ok'}, status: :ok}
        else
          format.js { render :template => 'passwords/forgot_error' }
          format.json {render json: {error: 'Email address not found. Please check and try again.'}, status: :not_found}
        end
      end
    end

  end

  def reset_submit
    token = params[:token].to_s

    if params[:email].blank?
      return render json: {error: 'Token not present'}
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password])
        render json: {status: 'ok'}, status: :ok
      else
        render json: {error: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {error:  ['Link not valid or expired. Try generating a new link.']}, status: :not_found
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
