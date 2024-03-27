class SettlementTypesController < ApplicationController
  before_action :set_settlement_type, only: %i[ show edit update destroy ]

  def index
    @settlement_types = SettlementType.all
    @settlements_without_type = Settlement.where(settlement_type_id: nil)
  end

  def show
  end

  def new
    @settlement_type = SettlementType.new
  end

  def edit
  end

  def create
    @settlement_type = SettlementType.new(settlement_type_params)
    if @settlement_type.save
      redirect_to settlement_type_url(@settlement_type), notice: "Категория населенного пункта успешно создана."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @settlement_type.update(settlement_type_params)
      redirect_to settlement_type_url(@settlement_type), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @settlement_type.destroy
    redirect_to settlement_type_url, notice: "Запись успешно удалена."
  end

  private
    
    def set_settlement_type
      @settlement_type = SettlementType.find(params[:id])
    end

    def settlement_type_params
      params.require(:settlement_type).permit(:name, :settlement_ids => [])
    end
end

