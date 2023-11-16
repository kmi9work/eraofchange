class PlantsController < ApplicationController
  before_action :set_plant, only: %i[ show edit update destroy ]

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
    if @plant.save
      redirect_to plant_url(@plant), notice: "Plant was successfully created."
    else
      render :new, status: :unprocessable_entity
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant
      @plant = Plant.find(params[:id])
    end

      # Only allow a list of trusted parameters through.
    def plant_params
      params.require(:plant).permit(:name, :category, :price, :level, :settlement_id, :plant_category_id)
    end

    def write_economic_subject
      es_id, es_type = params[:plant][:economic_subject].split('_')
      @plant.economic_subject_id = es_id
      @plant.economic_subject_type = es_type
    end
end




  
