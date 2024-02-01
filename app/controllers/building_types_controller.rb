class BuildingTypesController < ApplicationController
  before_action :set_building_type, only: %i[ show edit update destroy ]

  # GET /building_types or /building_types.json
  def index
    @building_types = BuildingType.all
  end

  # GET /building_types/1 or /building_types/1.json
  def show
  end

  # GET /building_types/new
  def new
    @building_type = BuildingType.new
  end

  # GET /building_types/1/edit
  def edit
  end

  # POST /building_types or /building_types.json
  def create
    @building_type = BuildingType.new(building_type_params)

    respond_to do |format|
      if @building_type.save
        format.html { redirect_to building_type_url(@building_type), notice: "Building type was successfully created." }
        format.json { render :show, status: :created, location: @building_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @building_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /building_types/1 or /building_types/1.json
  def update
    respond_to do |format|
      if @building_type.update(building_type_params)
        format.html { redirect_to building_type_url(@building_type), notice: "Building type was successfully updated." }
        format.json { render :show, status: :ok, location: @building_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @building_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /building_types/1 or /building_types/1.json
  def destroy
    @building_type.destroy

    respond_to do |format|
      format.html { redirect_to building_types_url, notice: "Building type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building_type
      @building_type = BuildingType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def building_type_params
      params.require(:building_type).permit(:title, :params)
    end
end
