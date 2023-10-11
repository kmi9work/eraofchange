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
  end

  def update
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
    params.require(:plant).permit(:name, :category, :price, :level, :location)
  end


end
