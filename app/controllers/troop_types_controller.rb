class TroopTypesController < ApplicationController
  before_action :set_troop_type, only: %i[ show edit update destroy ]

  # GET /troop_types or /troop_types.json
  def index
    @troop_types = TroopType.all
  end

  # GET /troop_types/1 or /troop_types/1.json
  def show
  end

  # GET /troop_types/new
  def new
    @troop_type = TroopType.new
  end

  # GET /troop_types/1/edit
  def edit
  end

  # POST /troop_types or /troop_types.json
  def create
    @troop_type = TroopType.new(troop_type_params)

    respond_to do |format|
      if @troop_type.save
        format.html { redirect_to troop_type_url(@troop_type), notice: "Troop type was successfully created." }
        format.json { render :show, status: :created, location: @troop_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @troop_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /troop_types/1 or /troop_types/1.json
  def update
    respond_to do |format|
      if @troop_type.update(troop_type_params)
        format.html { redirect_to troop_type_url(@troop_type), notice: "Troop type was successfully updated." }
        format.json { render :show, status: :ok, location: @troop_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @troop_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /troop_types/1 or /troop_types/1.json
  def destroy
    @troop_type.destroy

    respond_to do |format|
      format.html { redirect_to troop_types_url, notice: "Troop type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_troop_type
      @troop_type = TroopType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def troop_type_params
      params.require(:troop_type).permit(:name, :params)
    end
end
