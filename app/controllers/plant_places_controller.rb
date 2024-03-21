class PlantPlacesController < ApplicationController
  before_action :set_plant_place, only: %i[ show edit update destroy ]

  # GET /plant_places or /plant_places.json
  def index
    @plant_places = PlantPlace.all
  end

  # GET /plant_places/1 or /plant_places/1.json
  def show
  end

  # GET /plant_places/new
  def new
    @plant_place = PlantPlace.new
  end

  # GET /plant_places/1/edit
  def edit
  end

  # POST /plant_places or /plant_places.json
  def create
    @plant_place = PlantPlace.new(plant_place_params)

    respond_to do |format|
      if @plant_place.save
        format.html { redirect_to plant_place_url(@plant_place), notice: "Plant place was successfully created." }
        format.json { render :show, status: :created, location: @plant_place }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plant_places/1 or /plant_places/1.json
  def update
    respond_to do |format|
      if @plant_place.update(plant_place_params)
        format.html { redirect_to plant_place_url(@plant_place), notice: "Plant place was successfully updated." }
        format.json { render :show, status: :ok, location: @plant_place }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plant_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plant_places/1 or /plant_places/1.json
  def destroy
    @plant_place.destroy

    respond_to do |format|
      format.html { redirect_to plant_places_url, notice: "Plant place was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant_place
      @plant_place = PlantPlace.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plant_place_params
      params.require(:plant_place).permit(:title, :plant_category_id, :plant_ids => [])
    end
end
