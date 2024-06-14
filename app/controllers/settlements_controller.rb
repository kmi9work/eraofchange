class SettlementsController < ApplicationController
  before_action :set_settlement, only: %i[ show edit update destroy ]
  
  def index
    @settlements = Settlement.all
  end

  def show
  end

  def new
    @settlement = Settlement.new
    @ownerless_plants = Plant.where(settlement_id: nil)
  end

  def create
    @settlement = Settlement.new(settlement_params)
    respond_to do |format|
      if @settlement.save
        format.json { render :show, status: :created, location: @settlement }
        format.html { redirect_to settlement_url(@settlement), notice: "Населенный пункт успешно создан."}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @ownerless_plants = Plant.where(settlement_id: [nil, @settlement.id])
  end

  def update
    respond_to do |format|
      if @settlement.update(settlement_params)
        format.html { redirect_to settlement_url(@settlement), notice: "Населенный пункт успешно отредактирован." }
        format.json { render :show, status: :ok, location: @settlement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @settlement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @settlement.destroy

    respond_to do |format|
      format.html { redirect_to settlements_url, notice: "settlement was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def build
    @settlement = Settlement.find(params[:id])
    bulding_type_id = params[:building_type_id]
    result = @settlement.build(bulding_type_id)
    redirect_to settlement_url(@settlement), notice: result[:msg]
  end

  private
    
    def set_settlement
      @settlement = Settlement.find(params[:id])
    end

    def settlement_params
      params.require(:settlement).permit(:name, :settlement_type_id,  :region_id, :plant_place_ids => [] )
    end

end
