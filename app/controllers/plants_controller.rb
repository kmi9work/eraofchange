class PlantsController < ApplicationController
  def index
    @plants = Plant.all
    render 'index', layout: false
  end

  def show
    @plant = Plant.find(params[:id])
  end

  def new
    @plant = Plant.new
  end

  def create
    Plant.create(name: params[:name], category: params[:category], price: params[:price], 
    			level: params[:level], location: params[:location])
    redirect_to('/plants')
  end

  def edit
    @plant = Plant.find_by_id(params[:id])
  end

  def update
    @plant = Plant.find_by_id(params[:id])
    @plant.update(name: params[:name], category: params[:category], price: params[:price], 
    			level: params[:level], location: params[:location])
    redirect_to(plants_path)
  end

  def destroy
    @plant = Plant.find_by_id(params[:id])
    @plant.destroy
    redirect_to(plants_path)
  end
end
