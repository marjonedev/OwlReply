class PaymentmethodsController < ApplicationController
  before_action :logged_in_user
  before_action :set_paymentmethod, only: [:show, :edit, :update, :destroy]

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
  end

  # GET /paymentmethods/1/edit
  def edit
    @paymentmethods = current_user.paymentmethods
  end

  # POST /paymentmethods
  # POST /paymentmethods.json
  def create
    @paymentmethod = current_user.paymentmethods.new(paymentmethod_params)

    respond_to do |format|
      if @paymentmethod.save
        @paymentmethods = current_user.paymentmethods
        format.html { redirect_to @paymentmethod, notice: 'Paymentmethod was successfully created.' }
        format.json { render :show, status: :created, location: @paymentmethod }
        format.js {  }
      else
        format.html { render :new }
        format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
        format.js {  }
      end
    end
  end

  # PATCH/PUT /paymentmethods/1
  # PATCH/PUT /paymentmethods/1.json
  def update
    respond_to do |format|
      if @paymentmethod.update(paymentmethod_params)
        @paymentmethods = current_user.paymentmethods
        format.html { redirect_to @paymentmethod, notice: 'Paymentmethod was successfully updated.' }
        format.json { render :show, status: :ok, location: @paymentmethod }
        format.js {  }
      else
        format.html { render :edit }
        format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
        format.js {  }
      end
    end
  end

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
      params.require(:paymentmethod).permit(:default, :card_number, :customer_id, :card_cvc, :card_exp_month, :card_exp_year, :card_brand, :card_funding)
    end
end
