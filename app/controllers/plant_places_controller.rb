class PlantPlacesController < ApplicationController
  before_action :set_plant_place, only: %i[ show edit update destroy ]

  # GET /plant_places or /plant_places.json
  def index
    @plant_places = PlantPlace.all
  end

  # GET /plant_places/1 or /plant_places/1.json
  def show
  end

  # GET /plant_places/available_places
  # API метод для получения доступных мест строительства для каждого типа предприятия
  def available_places
    craftsmen_technology = Technology.find_by(id: Technology::CRAFTSMEN)
    craftsmen_open = craftsmen_technology&.is_open == 1
    craftsmen_tech_name = craftsmen_technology&.name || "Ремесловые люди"
    craftsmen_required_names = ["Кузница", "Ювелирная мастерская"]

    result = PlantType.all.map do |plant_type|
      # Для перерабатывающих предприятий - все PlantPlace с категорией "Перерабатывающее"
      # Для добывающих - только PlantPlace, которые связаны с нужным fossil_type
      if plant_type.plant_category_id == PlantCategory::PROCESSING
        available_places = PlantPlace.includes(:region)
                                      .where(plant_category_id: PlantCategory::PROCESSING)
      else
        # Добывающее предприятие
        if plant_type.fossil_type_id.present?
          # Находим PlantPlace, которые содержат нужный fossil_type
          available_places = PlantPlace.includes(:region, :fossil_types)
                                        .where(plant_category_id: PlantCategory::EXTRACTIVE)
                                        .joins(:fossil_types)
                                        .where(fossil_types: { id: plant_type.fossil_type_id })
        else
          available_places = []
        end
      end

      technology_requirements = []
      if craftsmen_required_names.include?(plant_type.name)
        technology_requirements << {
          id: Technology::CRAFTSMEN,
          name: craftsmen_tech_name,
          open: craftsmen_open
        }
      end

      {
        plant_type_id: plant_type.id,
        plant_type_name: plant_type.name,
        plant_category: plant_type.plant_category&.name,
        plant_category_id: plant_type.plant_category_id,
        technology_requirements: technology_requirements,
        available_places: available_places.map do |place|
          region = place.region
          belongs_to_rus = region&.country_id == Country::RUS

          {
            id: place.id,
            name: place.name,
            region_id: place.region_id,
            region_name: region&.name,
            region_country_id: region&.country_id,
            allowed: belongs_to_rus
          }
        end
      }
    end

    render json: result
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
      params.require(:plant_place).permit(:name, :plant_category_id, :plant_ids => [], :fossil_type_ids => [])
    end
end
