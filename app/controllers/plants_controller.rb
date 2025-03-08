class PlantsController < ApplicationController
  before_action :set_plant, only: %i[ show edit update destroy name_of_plant upgrade has_produced ]

  def name_of_plant
    @plant.name_of_plant
  end

  def upgrade
    @plant.upgrade!
  end

  def has_produced
    @plant.has_produced!
  end

  def index
    @plants = Plant.all
  end

  def show
  end

  def new
    @plant = Plant.new
  end

  def edit
  end

  def create
    @plant = Plant.new(plant_params)
    write_economic_subject
    
    respond_to do |format|
      if @plant.save
        format.html { redirect_to plant_url(@plant), notice: "Plant was successfully created." }
        format.json { render :show, status: :created, location: @plant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @plant.assign_attributes(plant_params)
    write_economic_subject
    if @plant.save
      redirect_to plant_url(@plant)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant.destroy
    redirect_to(plants_path)
  end

  def upgrade
    @plant_to_upgrade = Plant.find(params[:id])
    @plant_to_upgrade.upgrade!
    redirect_back(fallback_location: plant_path(@plant_to_upgrade))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant
      @plant = Plant.find(params[:id])
    end

      # Only allow a list of trusted parameters through.
    def plant_params
      params.require(:plant).permit(:comments, :plant_level_id, :plant_place_id, :credit_id)
    end

    def write_economic_subject
      es_id, es_type = params[:plant][:economic_subject].split('_')
      @plant.economic_subject_id = es_id
      @plant.economic_subject_type = es_type
    end
end




  
