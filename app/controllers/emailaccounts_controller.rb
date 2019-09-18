class EmailaccountsController < ApplicationController
  before_action :logged_in_user
  before_action :set_emailaccount, only: [:show, :edit, :update, :destroy, :check_again]

  # GET /emailaccounts
  # GET /emailaccounts.json
  def index
    @emailaccounts = current_user.emailaccounts
  end

  # GET /emailaccounts/1
  # GET /emailaccounts/1.json
  def show
    @replies = @emailaccount.replies.order("created_at DESC")
  end

  # GET /emailaccounts/new
  def new
    @emailaccount = Emailaccount.new
  end

  # GET /emailaccounts/1/edit
  def edit
  end

  # POST /emailaccounts
  # POST /emailaccounts.json
  def create
    @emailaccount = current_user.emailaccounts.new(emailaccount_params)

    respond_to do |format|
      if @emailaccount.save
        format.html { redirect_to @emailaccount, notice: 'Email account was successfully created.' }
        format.json { render :show, status: :created, location: @emailaccount }
        format.js {  }
      else
        format.js { render :new }
        format.html { render :new }
        format.json { render json: @emailaccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /emailaccounts/1
  # PATCH/PUT /emailaccounts/1.json
  def update
    respond_to do |format|
      if @emailaccount.update(emailaccount_params)
        format.html { redirect_to @emailaccount, notice: 'Email account was successfully updated.' }
        format.json { render :show, status: :ok, location: @emailaccount }
        format.js { redirect_to @emailaccount, notice: 'Email account was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @emailaccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /emailaccounts/1
  # DELETE /emailaccounts/1.json
  def destroy
    @emailaccount.destroy
    respond_to do |format|
      format.html { redirect_to emailaccounts_url, notice: 'Email Account was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def check_again
    @emailaccount.update_attribute(:last_checked, nil)
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_emailaccount
      @emailaccount = current_user.emailaccounts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def emailaccount_params
      params
          .require(:emailaccount)
          .permit(:address, :password, :encrypted_password, :encryption_key, :template)
    end
end
