class RecourcesController < ApplicationController
  before_action :set_recource, only: %i[ show edit update destroy ]

  def index
    @recources = Recource.all
  end

  def show
  end

  def new
    @recource = Recource.new
  end

  def edit
  end

  def create
    @recource = Recource.new(recource_params)
    if @recource.save
      redirect_to recource_url(@recource), notice: "Ресурс успешно создан."
    else
      render :new, status: :unprocessable_entity 
    end
  end

  def update
    if @recource.update(recource_params)
      redirect_to recource_url(@recource), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recource.destroy
    redirect_to recources_url, notice: "Запись успешно удалена."
  end

  private
    
    def set_recource
      @recource = Recource.find(params[:id])
    end

    def recource_params
      params.require(:recource).permit(:name, :price)
    end
end
