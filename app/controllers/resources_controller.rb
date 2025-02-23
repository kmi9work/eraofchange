class ResourcesController < ApplicationController
  before_action :set_resource, only: %i[ show edit update destroy ]

  def index
    @resources = Resource.all
  end

  def show
  end

  def show_prices
    @prices = Resource.show_prices
  end

  def send_caravan
    @caravan = Resource.send_caravan(params[:country_id], params[:res_pl_sells], params[:res_pl_buys], params[:gold])
  end

  def new
    @resource = Resource.new
  end

  def edit
  end

  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      redirect_to resource_url(@resource), notice: "Ресурс успешно создан."
    else
      render :new, status: :unprocessable_entity 
    end
  end

  def update
    if @resource.update(resource_params)
      redirect_to resource_url(@resource), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    redirect_to resources_url, notice: "Запись успешно удалена."
  end

  private
    
    def set_resource
      @resource = Resource.find(params[:id])
    end

    def resource_params
      params.require(:resource).permit(:name, :price)
    end
end
