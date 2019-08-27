class PlansController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  # This is a Controller-Only function that sort of wraps the "Subscription".
  # This user-facing interface is what allows a user to change their subscription plan.

  def index
    @plans = Subscription.where(secret: false)
    render file: "pages/pricing"
  end

  def update
    current_user.set_subscription!(@subscription)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

end
