class MerchantsController < ApplicationController
  before_action :set_merchant, only: %i[ show edit update destroy ]

  def index
    @merchants = Merchant.all
  end

  def show
  end

  def new
    @merchant = Merchant.new
  end

  def edit
  end

  def create
    @merchant = Merchant.new(merchant_params)
    if @merchant.save
      redirect_to merchant_url(@merchant), notice: "Купец успешно создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @merchant.update(merchant_params)
      redirect_to merchant_url(@merchant), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @merchant.destroy
    redirect_to merchants_url, notice: "Запись успешно удалена."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merchant
      @merchant = Merchant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def merchant_params
      params.require(:merchant).permit(:name, :guild_id, :player_id, :family_id, :plant_ids => [])
    end
end
