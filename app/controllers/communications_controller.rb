class CommunicationsController < ApplicationController
  include SessionsHelper
  before_action :logged_in_user
  before_action :set_communication, only: [:new, :create, :edit, :update, :destroy]

  def index
    @communications = Communication.all.order("created_at DESC")
  end

  def show
  end

  def new
    @communication = Communication.new
  end

  def edit
  end

  def create
    @communication = @communication.new(communication_params)
    respond_to do |format|
      if @communication.save
        format.js { }
      else
        format.js { }
      end
    end
  end

  def update
    respond_to do |format|
      if @communication.update(communication_params)
        format.js { }
      else
        format.js { }
      end
    end
  end

  def destroy
    @communication.destroy
    respond_to do |format|
      format.js { }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # Never trust parameters from the scary internet, only allow the white list through.
  def communication_params
    params.require(:communication)
        .permit(:keywords, :body, :negative_keywords, :catchcall)
  end

  def set_communication
    @communication = Communication.find(params[:id]) # if current_user.admin? #current_user.emailaccounts.find(params[:emailaccount_id])
  end
end
