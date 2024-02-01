class BuildingLevelsController < ApplicationController
  before_action :set_building_level, only: %i[ show edit update destroy ]

  # GET /building_levels or /building_levels.json
  def index
    @building_levels = BuildingLevel.all
  end

  # GET /building_levels/1 or /building_levels/1.json
  def show
  end

  # GET /building_levels/new
  def new
    @building_level = BuildingLevel.new
  end

  # GET /building_levels/1/edit
  def edit
  end

  # POST /building_levels or /building_levels.json
  def create
    @building_level = BuildingLevel.new(building_level_params)

    respond_to do |format|
      if @building_level.save
        format.html { redirect_to building_level_url(@building_level), notice: "Building level was successfully created." }
        format.json { render :show, status: :created, location: @building_level }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @building_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /building_levels/1 or /building_levels/1.json
  def update
    respond_to do |format|
      if @building_level.update(building_level_params)
        format.html { redirect_to building_level_url(@building_level), notice: "Building level was successfully updated." }
        format.json { render :show, status: :ok, location: @building_level }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @building_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /building_levels/1 or /building_levels/1.json
  def destroy
    @building_level.destroy

    respond_to do |format|
      format.html { redirect_to building_levels_url, notice: "Building level was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building_level
      @building_level = BuildingLevel.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def building_level_params
      params.require(:building_level).permit(:level, :price, :params, :building_type_id)
    end
end
