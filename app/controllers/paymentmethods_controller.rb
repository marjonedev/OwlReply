class PaymentmethodsController < ApplicationController
  before_action :set_paymentmethod, only: [:show, :edit, :update, :destroy]

  # GET /paymentmethods
  # GET /paymentmethods.json
  def index
    @paymentmethods = Paymentmethod.all
  end

  # GET /paymentmethods/1
  # GET /paymentmethods/1.json
  def show
  end

  # GET /paymentmethods/new
  def new
    @paymentmethod = Paymentmethod.new
  end

  # GET /paymentmethods/1/edit
  def edit
  end

  # POST /paymentmethods
  # POST /paymentmethods.json
  def create
    @paymentmethod = Paymentmethod.new(paymentmethod_params)

    respond_to do |format|
      if @paymentmethod.save
        format.html { redirect_to @paymentmethod, notice: 'Paymentmethod was successfully created.' }
        format.json { render :show, status: :created, location: @paymentmethod }
      else
        format.html { render :new }
        format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /paymentmethods/1
  # PATCH/PUT /paymentmethods/1.json
  def update
    respond_to do |format|
      if @paymentmethod.update(paymentmethod_params)
        format.html { redirect_to @paymentmethod, notice: 'Paymentmethod was successfully updated.' }
        format.json { render :show, status: :ok, location: @paymentmethod }
      else
        format.html { render :edit }
        format.json { render json: @paymentmethod.errors, status: :unprocessable_entity }
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
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paymentmethod
      @paymentmethod = Paymentmethod.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paymentmethod_params
      params.require(:paymentmethod).permit(:user_id, :method, :card_name, :card_type, :customer_id, :card_exp_date)
    end
end
