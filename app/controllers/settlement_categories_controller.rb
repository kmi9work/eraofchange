class SettlementCategoriesController < ApplicationController
  before_action :set_settlement_category, only: %i[ show edit update destroy ]

  def index
    @settlement_categories = SettlementCategory.all
  end

  def show
  end

  def new
    @settlement_category = SettlementCategory.new
  end

  def edit
  end

  def create
    @settlement_category = SettlementCategory.new(settlement_category_params)
    if @settlement_category.save
      redirect_to settlement_category_url(@settlement_category), notice: "Категория населенного пункта успешно создана."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @settlement_category.update(settlement_category_params)
      redirect_to settlement_category_url(@settlement_category), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @settlement_category.destroy
    redirect_to settlement_categories_url, notice: "Запись успешно удалена."
  end

  private
    
    def set_settlement_category
      @settlement_category = SettlementCategory.find(params[:id])
    end

    def settlement_category_params
      params.require(:settlement_category).permit(:name, :settlement_ids => [])
    end
end

