class IgnoredwordsController < ApplicationController
  before_action :require_login
  before_action :set_ignoredword, only: [:show, :edit, :update, :destroy]

  # GET /replies
  # GET /replies.json
  def index
    @ignoredwords = current_user.ignoredwords
  end

  # GET /replies/1
  # GET /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @ignoredword = Ignoredword.new
  end

  # GET /replies/1/edit
  def edit
  end

  # POST /replies
  # POST /replies.json
  def create
    @ignoredword = current_user.ignoredwords.new(ignoredword_params)

    respond_to do |format|
      if @ignoredword.save
        format.html { redirect_to @ignoredword, notice: 'Reply was successfully created.' }
        format.json { render :show, status: :created, location: @reply }
        format.js {  }
      else
        format.html { render :new }
        format.json { render json: @ignoredword.errors, status: :unprocessable_entity }
        format.js {  }
      end
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    respond_to do |format|
      if @ignoredword.update(ignoredword_params)
        format.html { redirect_to @ignoredword, notice: 'Reply was successfully updated.' }
        format.json { render :show, status: :ok, location: @ignoredword }
        format.js {  }
      else
        format.html { render :edit }
        format.json { render json: @ignoredword.errors, status: :unprocessable_entity }
        format.js {  }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.json
  def destroy
    @ignoredword.destroy
    respond_to do |format|
      format.js {  }
      format.html { redirect_to ignoredword_url, notice: 'Ignored word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ignoredword
      @ignoredword = current_user.ignoredwords.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ignoredword_params
      params.require(:ignoredword)
          .permit(:word)
    end
end
