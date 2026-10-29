class BuildingsController < ApplicationController
  before_action :set_building, only: %i[ show edit update destroy upgrade pay_for_maintenance]

  # GET /buildings or /buildings.json
  def index
    @buildings = Building.all
  end

  def upgrade
    @building.upgrade!(params[:zodchiy_bonus])
  end

  def pay_for_maintenance
    @building.pay_for_maintenance
  end

  # GET /buildings/1 or /buildings/1.json
  def show
  end

  # GET /buildings/new
  def new
    @building = Building.new
  end

  # GET /buildings/1/edit
  def edit
  end

  # POST /buildings or /buildings.json
  def create
    @building = Building.new(building_params)

    respond_to do |format|
      if @building.save
        format.html { redirect_to building_url(@building), notice: "Building was successfully created." }
        format.json { render :show, status: :created, location: @building }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buildings/1 or /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to building_url(@building), notice: "Building was successfully updated." }
        format.json { render :show, status: :ok, location: @building }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buildings/1 or /buildings/1.json
  # ?delete_influence=1 — удалить вместе с постройкой и начисленное за неё
  # влияние (штрафы за неоплаченную церковь). Без параметра история остаётся:
  # удаление церкви само по себе её не отзывает.
  def destroy
    deleted_influence = 0
    if ActiveModel::Type::Boolean.new.cast(params[:delete_influence])
      deleted_influence = @building.influence_items.destroy_all.size
    end
    @building.destroy

    respond_to do |format|
      format.html { redirect_to buildings_url, notice: "Building was successfully destroyed." }
      format.json { render json: { success: true, deleted_influence: deleted_influence } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def building_params
      params.require(:building).permit(:comment, :params, :building_level_id, :settlement_id)
    end
end
