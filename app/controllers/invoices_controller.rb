class InvoicesController < ApplicationController
  before_action :logged_in_user
  before_action :set_invoice, only: [:show, :update]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = current_user.invoices
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
  end

  # This is for paying an unpaid invoice only!
  def update
    charge = @invoice.charge_card
    if charge
      redirect_to '/invoices', notice: 'Invoice successfully paid.'
    else
      redirect_to '/paymentmethods', notice: 'Payment method was declined.'
    end
  end

=begin
  An invoice will almost never be deleted, edited, or created by the controller. Only monthly processes will ever create or edit an invoice.
  MAYBE "Edit" can be used for applying credits and adjustments in the future if necessary.

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
=end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = current_user.invoices.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:user_id, :amount, :amount_paid, :date_paid, :transaction_id)
    end
end
