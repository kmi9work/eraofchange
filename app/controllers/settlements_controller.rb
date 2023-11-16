class SettlementsController < ApplicationController
  before_action :set_settlement, only: %i[ show edit update destroy ]
  
  def index
    @settlements = Settlement.all
  end

  def show
  end

  def new
    @settlement = Settlement.new
  end

  def create
    @settlement = Settlement.new(settlement_params)
    if @settlement.save
      redirect_to settlement_url(@settlement), notice: "Населенный пункт успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @settlement.update(settlement_params)
      redirect_to settlement_url(@settlement), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @settlement.destroy
    redirect_to settlements_path, notice: "Запись успешно удалена."
  end

  private
    
    def set_settlement
      @settlement = Settlement.find(params[:id])
    end

    def settlement_params
      params.require(:settlement).permit(:name, :settlement_category_id, :plant_ids => [] )
    end

end
