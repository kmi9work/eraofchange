class BuildingPlacesController < ApplicationController
  before_action :set_building_place, only: %i[ show edit update destroy ]

  # GET /building_places or /building_places.json
  def index
    @building_places = BuildingPlace.all
  end

  # GET /building_places/1 or /building_places/1.json
  def show
  end

  # GET /building_places/new
  def new
    @building_place = BuildingPlace.new
  end

  # GET /building_places/1/edit
  def edit
  end

  # POST /building_places or /building_places.json
  def create
    @building_place = BuildingPlace.new(building_place_params)

    respond_to do |format|
      if @building_place.save
        format.html { redirect_to building_place_url(@building_place), notice: "Building place was successfully created." }
        format.json { render :show, status: :created, location: @building_place }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @building_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /building_places/1 or /building_places/1.json
  def update
    respond_to do |format|
      if @building_place.update(building_place_params)
        format.html { redirect_to building_place_url(@building_place), notice: "Building place was successfully updated." }
        format.json { render :show, status: :ok, location: @building_place }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @building_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /building_places/1 or /building_places/1.json
  def destroy
    @building_place.destroy

    respond_to do |format|
      format.html { redirect_to building_places_url, notice: "Building place was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building_place
      @building_place = BuildingPlace.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def building_place_params
      params.require(:building_place).permit(:category, :params)
    end
end
