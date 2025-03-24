class RegionsController < ApplicationController
  before_action :set_region, only: %i[ show edit update destroy modify_public_order captured_by add_po_item]

  # GET /regions or /regions.json
  def index
    @regions = Region.all
    @regions = @regions.where.not(country_id: Country::RUS) if params[:foreign].to_i == 1
    @regions = @regions.where(country_id: Country::RUS) if params[:foreign].to_i == 0
  end

  def captured_by
    @region.captured_by(params[:country_id], params[:how])
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
end
