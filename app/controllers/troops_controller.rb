class TroopsController < ApplicationController
  before_action :set_troop, only: %i[ show edit update destroy pay_for upgrade ]

  def pay_for
    @troop.pay_for
  end

  # GET /troops or /troops.json
  def index
    @troops = Troop.all
  end

  # GET /troops/1 or /troops/1.json
  def show
  end

  # GET /troops/new
  def new
    @troop = Troop.new
  end

  # GET /troops/1/edit
  def edit
  end

  def upgrade
    @troop.troop_type_id = params[:target_type_id]
    @troop.save
    render :show, status: :created, location: @troop
  end

  # POST /troops or /troops.json
  def create
    @troop = Troop.new(troop_params)

    respond_to do |format|
      if @troop.save
        format.html { redirect_to troop_url(@troop), notice: "Troop was successfully created." }
        format.json { render :show, status: :created, location: @troop }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @troop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /troops/1 or /troops/1.json
  def update
    respond_to do |format|
      if @troop.update(troop_params)
        format.html { redirect_to troop_url(@troop), notice: "Troop was successfully updated." }
        format.json { render :show, status: :ok, location: @troop }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @troop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /troops/1 or /troops/1.json
  def destroy
    @troop.destroy

    respond_to do |format|
      format.html { redirect_to troops_url, notice: "Troop was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_troop
      @troop = Troop.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def troop_params
      params.require(:troop).permit(:troop_type_id, :is_hired, :army_id)
    end
end
