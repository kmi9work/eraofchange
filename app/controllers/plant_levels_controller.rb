class PlantLevelsController < ApplicationController
  before_action :set_plant_level, only: %i[ show edit update destroy ]

  # GET /plant_levels or /plant_levels.json
  def index
    @plant_levels = PlantLevel.all
  end

  # GET /plant_levels/1 or /plant_levels/1.json
  def show
  end

  # GET /plant_levels/new
  def new
    @plant_level = PlantLevel.new
  end

  # GET /plant_levels/1/edit
  def edit
  end

  # POST /plant_levels or /plant_levels.json
  def create
    @plant_level = PlantLevel.new(plant_level_params)

    respond_to do |format|
      if @plant_level.save
        format.html { redirect_to plant_level_url(@plant_level), notice: "Plant level was successfully created." }
        format.json { render :show, status: :created, location: @plant_level }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plant_levels/1 or /plant_levels/1.json
  def update
    respond_to do |format|
      if @plant_level.update(plant_level_params)
        format.html { redirect_to plant_level_url(@plant_level), notice: "Plant level was successfully updated." }
        format.json { render :show, status: :ok, location: @plant_level }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plant_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plant_levels/1 or /plant_levels/1.json
  def destroy
    @plant_level.destroy

    respond_to do |format|
      format.html { redirect_to plant_levels_url, notice: "Plant level was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant_level
      @plant_level = PlantLevel.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plant_level_params
      params.require(:plant_level).permit(:level, :deposit, :charge, :formula, :price, :max_product, :plant_type_id, :plant_ids => [])
    end
end
