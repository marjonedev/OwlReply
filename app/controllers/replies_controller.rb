class RepliesController < ApplicationController
  include SessionsHelper
  before_action :logged_in_user
  before_action :set_reply, only: [:show, :edit, :update, :destroy]
  before_action :set_emailaccount, only: [:new, :create, :edit, :update, :destroy]

  # GET /replies
  # GET /replies.json
  def index
    @replies = Reply.all.order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.js { }
    end
  end

  # GET /replies/1
  # GET /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit
  end

  # POST /replies
  # POST /replies.json
  def create
    @reply = @emailaccount.replies.new(reply_params)

    respond_to do |format|
      if @reply.save
        format.html { redirect_to @reply, notice: 'Reply was successfully created.' }
        format.json { render :show, status: :created, location: @reply }
        format.js {  }
      else
        format.html { render :new }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
        format.js {  }
      end
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        format.html { redirect_to @reply, notice: 'Reply was successfully updated.' }
        format.json { render :show, status: :ok, location: @reply }
        format.js {  }
      else
        format.html { render :edit }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
        format.js {  }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.json
  def destroy
    @reply.destroy
    respond_to do |format|
      format.js {  }
      format.html { redirect_to replies_url, notice: 'Reply was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reply
      #@reply = Reply.find(params[:id])
      @reply = current_user.replies.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reply_params
      params.require(:reply)
          .permit(:keywords, :body, :negative_keywords, :catchcall)
    end

  def set_emailaccount
    @emailaccount = current_user.emailaccounts.find(params[:emailaccount_id])
  end
end
