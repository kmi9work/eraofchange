class CreditsController < ApplicationController
  before_action :set_credit, only: %i[ show edit update destroy ]

  # GET /credits or /credits.json
  def index
    @credits = Credit.all
  end

  # GET /credits/1 or /credits/1.json
  def show
  end

  # GET /credits/new
  def new
    @credit = Credit.new
  end

  # GET /credits/1/edit
  def edit
  end

  # POST /credits or /credits.json
  def create
    @credit = Credit.new(credit_params)

    respond_to do |format|
      if @credit.save
        format.html { redirect_to credit_url(@credit), notice: "Credit was successfully created." }
        format.json { render :show, status: :created, location: @credit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /credits/1 or /credits/1.json
  def update
    respond_to do |format|
      if @credit.update(credit_params)
        format.html { redirect_to credit_url(@credit), notice: "Credit was successfully updated." }
        format.json { render :show, status: :ok, location: @credit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credits/1 or /credits/1.json
  def destroy
    @credit.destroy

    respond_to do |format|
      format.html { redirect_to credits_url, notice: "Credit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credit
      @credit = Credit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def credit_params
      params.require(:credit).permit(:sum, :deposit, :procent, :start_year, :duration, :player_id)
    end
end
