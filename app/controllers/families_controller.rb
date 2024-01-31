class FamiliesController < ApplicationController
  before_action :set_family, only: %i[ show edit update destroy ]

  def index
    @families = Family.all
  end

  def show
  end

  def new
    @family = Family.new
    @merches = Merchant.where(guild_id: nil)
  end

  def edit
    @merches = Merchant.where(guild_id: [nil, @family.id])
  end

  def create
    @family = Family.new(family_params)
    if @family.save
      redirect_to family_url(@family), notice: "Семья успешно создана."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @family.update(family_params)
      redirect_to family_url(@family), notice: "Семья успешно изменена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @family.destroy
    redirect_to families_url, notice: "Семья успешно удалена."
  end

  private
    def set_family
      @family = Family.find(params[:id])
    end

    def family_params
      params.require(:family).permit(:name, :merchant_ids => [])
    end
end
