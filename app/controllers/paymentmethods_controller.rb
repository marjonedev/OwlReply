class PaymentmethodsController < ApplicationController
  before_action :logged_in_user
  before_action :set_paymentmethod, only: [:show, :edit, :update, :destroy, :toggle_default]

  # GET /paymentmethods
  # GET /paymentmethods.json
  def index
    @paymentmethods = current_user.paymentmethods
  end

  # GET /paymentmethods/1
  # GET /paymentmethods/1.json
  def show
  end

  # GET /paymentmethods/new
  def new
    @paymentmethod = Paymentmethod.new
    @paymentmethods = current_user.paymentmethods

    if(params.has_key?(:upgrade))
      session[:upgrade] = params[:upgrade]
    end
  end


  # GET /paymentmethods/1/edit
  # def edit
  #   @paymentmethods = current_user.paymentmethods
  # end

  def toggle_default
    respond_to do |format|
      @paymentmethod = Paymentmethod.find(params[:id])
      if @paymentmethod.default
        @paymentmethod.update_attribute(:default, false)
        @default = false
      else
        @paymentmethod.update_attribute(:default, true)
        @default = true
      end

      @paymentmethods = current_user.paymentmethods
      format.js {}
    end



  end

  # POST /paymentmethods
  # POST /paymentmethods.json
  def create
    @paymentmethod = current_user.paymentmethods.new(paymentmethod_params)

    respond_to do |format|
      if session[:upgrade]
        @subscription = Subscription.find(session[:upgrade])
        if @paymentmethod.save
          current_user.set_subscription!(@subscription)
          format.html { redirect_to root_url, notice: "Your account have been successfully upgraded to #{@subscription.name}" }
        else
          format.js {  }
          format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
        end
      else
        if @paymentmethod.save
          @paymentmethods = current_user.paymentmethods
          format.js {  }
          # format.html { redirect_to @paymentmethod, notice: 'Paymentmethod was successfully created.' }
          format.json { render :show, status: :created, location: @paymentmethod }
        else
          format.js {  }
          # format.html { render :new }
          format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /paymentmethods/1
  # PATCH/PUT /paymentmethods/1.json
  # def update
  #   respond_to do |format|
  #     if @paymentmethod.update(update_params)
  #       @paymentmethods = current_user.paymentmethods
  #       format.html { redirect_to @paymentmethod, notice: 'Paymentmethod was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @paymentmethod }
  #       format.js {  }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
  #       format.js {  }
  #     end
  #   end
  # end

  # DELETE /paymentmethods/1
  # DELETE /paymentmethods/1.json
  def destroy
    @paymentmethod.destroy
    respond_to do |format|
      format.html { redirect_to paymentmethods_url, notice: 'Paymentmethod was successfully destroyed.' }
      format.json { head :no_content }
      format.js {  }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paymentmethod
      @paymentmethod = current_user.paymentmethods.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paymentmethod_params
      params.require(:paymentmethod).permit(:default, :card_number, :token, :card_exp_month, :card_exp_year, :card_brand)
    end

    #only allow default parameter to be updated
    def toggle_default_params
      params.require(:paymentmethod).permit(:default)
    end
end
