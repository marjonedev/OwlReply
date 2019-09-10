class PlansController < ApplicationController
  before_action :set_subscription, only: [:update]
  # This is a Controller-Only function that sort of wraps the "Subscription".
  # This user-facing interface is what allows a user to change their subscription plan.

  def index
    @plans = Subscription.where(secret: false)
    render file: "pages/pricing"
  end

  def update
    respond_to do |format|
      if current_user.no_paymentmethods?
        format.js { redirect_to '/paymentmethods/new' }
      else
        current_user.set_subscription!(@subscription)
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

end
