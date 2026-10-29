class RegionsController < ApplicationController
  before_action :set_region, only: %i[ show edit update destroy modify_public_order captured_by add_po_item]

  # GET /regions or /regions.json
  def index
    @regions = Region.all
    if params[:country_id].present?
      # Явная страна (для Дашборда) имеет приоритет над «свой/зарубеж»
      @regions = @regions.where(country_id: params[:country_id])
      @regions_country = Country.find_by(id: params[:country_id]) || current_country
    else
      @regions = @regions.foreign_to(current_country) if params[:foreign].to_i == 1
      @regions = @regions.for_country(current_country) if params[:foreign].to_i == 0
      @regions_country = current_country
    end
  end

  # PATCH /regions/:id/captured_by.json?country_id=&how=&posol_bonus=1&grand_prince_bonus=1
  #   &remove_posol_bonus=1&remove_grand_prince_bonus=1
  #
  # Влияние за землю (Посольский дьяк +7, Великий князь +5) начисляется только по
  # решению мастера: клиент спрашивает отдельно по каждой должности «начислить
  # бонус» или «мастерское действие». Флаги `remove_*` — снятие бонуса у прежнего
  # государства, когда земля уходит другим игрокам.
  def captured_by
    result = @region.captured_by(params[:country_id], params[:how], land_bonus_params)
    render json: result
  end

  def modify_public_order
    @region.modify_public_order(params[:arg])
  end

  # GET /regions/1 or /regions/1.json
  def show
  end

  # GET /regions/new
  def new
    @region = Region.new
  end

  # GET /regions/1/edit
  def edit
  end

  # POST /regions or /regions.json
  def create
    @region = Region.new(region_params)

    respond_to do |format|
      if @region.save
        format.html { redirect_to region_url(@region), notice: "Region was successfully created." }
        format.json { render :show, status: :created, location: @region }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regions/1 or /regions/1.json
  def update
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to region_url(@region), notice: "Region was successfully updated." }
        format.json { render :show, status: :ok, location: @region }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regions/1 or /regions/1.json
  def destroy
    @region.destroy

    respond_to do |format|
      format.html { redirect_to regions_url, notice: "Region was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_po_item
    value = params[:value].to_i
    comment = params[:comment].presence || "Ручная правка"
    @region.add_po_item(value, comment, nil)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region
      @region = Region.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def region_params
      params.require(:region).permit(:name, :params)
    end

    # Решение мастера по влиянию за землю: начислить/снять бонус каждой должности
    # (см. Region#captured_by). Отсутствие параметра = «мастерское действие»,
    # влияние в системе не меняется.
    def land_bonus_params
      {
        posol: params[:posol_bonus].to_i == 1,
        grand_prince: params[:grand_prince_bonus].to_i == 1,
        remove_posol: params[:remove_posol_bonus].to_i == 1,
        remove_grand_prince: params[:remove_grand_prince_bonus].to_i == 1
      }
    end
end
