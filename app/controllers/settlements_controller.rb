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
        format.html { redirect_to settlement_url(@settlement), notice: "settlement was successfully created." }
        format.json { render :show, status: :created, location: @settlement }
      redirect_to settlement_url(@settlement), notice: "Населенный пункт успешно создан."
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
        format.html { redirect_to settlement_url(@settlement), notice: "settlement was successfully updated." }
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

  def build_church
    @settlement = Settlement.find(params[:id])
    which_settlement = @settlement.id
    which_building = BuildingLevel.find_by(name: "Часовня")
    Building.create(settlement_id: which_settlement, building_level: which_building)
    redirect_to settlement_url(@settlement), notice: "Во владении построена часовня."
  end

  def build_market
    @settlement = Settlement.find(params[:id])
    which_settlement = @settlement.id
    which_building = BuildingLevel.find_by(name: "Базар" )
    Building.create(settlement_id: which_settlement, building_level: which_building)
    redirect_to settlement_url(@settlement), notice: "Во владении построен рынок."
  end


  def build_fort
    @settlement = Settlement.find(params[:id])
    if @settlement.settlement_type.name == "Город"
      which_settlement = @settlement.id
      which_building = BuildingLevel.find_by(name: "Форт" )
      Building.create(settlement_id: which_settlement, building_level: which_building)
    else
      puts "В деревне нельзя строить оборонительные сооружения"
    end
    redirect_to settlement_url(@settlement), notice: "Во владении построен рынок."
  end

  def build_garrison
    @settlement = Settlement.find(params[:id])
    if @settlement.settlement_type.name == "Город"
      which_settlement = @settlement.id
      which_building = BuildingLevel.find_by(name: "Караул" )
      Building.create(settlement_id: which_settlement, building_level: which_building)
    else
      puts "В деревне нельзя размещать гарнизон"
    end
    redirect_to settlement_url(@settlement), notice: "Во владении построен рынок."
  end

  def building_upgrade
    #byebug
    #@which_settlement = Settlement.find(params[:id])
    @building_to_upgrade = Building.find_by(params[:id])
    if @building_to_upgrade.building_level.level < 3
    next_level = @building_to_upgrade.building_level.level + 1
      required_building_type = @building_to_upgrade.building_level.building_type
      @building_to_upgrade.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
      @building_to_upgrade.save
    end
        #redirect_to settlement_url(@settlement)
   end


  private
    
    def set_settlement
      @settlement = Settlement.find(params[:id])
    end

    def settlement_params
      params.require(:settlement).permit(:name, :settlement_type_id,  :region_id, :plant_place_ids => [] )
    end

end
