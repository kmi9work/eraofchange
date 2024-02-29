class PlantTypesController < ApplicationController
  before_action :set_plant_type, only: %i[ show edit update destroy ]

  def index
    @plant_types = PlantType.all
  end

  
  def show
  end

  
  def new
    @plant_type = PlantType.new
  end

  
  def edit
  end

  def create
    @plant_type = PlantType.new(plant_type_params)

    respond_to do |format|
      if @plant_type.save
        format.html { redirect_to plant_type_url(@plant_type), notice: "Plant type was successfully created." }
        format.json { render :show, status: :created, location: @plant_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant_type.errors, status: :unprocessable_entity }
      end
    end
  end

  
  def update
    respond_to do |format|
      if @plant_type.update(plant_type_params)
        format.html { redirect_to plant_type_url(@plant_type), notice: "Plant type was successfully updated." }
        format.json { render :show, status: :ok, location: @plant_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plant_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plant_types/1 or /plant_types/1.json
  def destroy
    @plant_type.destroy

    respond_to do |format|
      format.html { redirect_to plant_types_url, notice: "Plant type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant_type
      @plant_type = PlantType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plant_type_params
      #params.fetch(:plant_type, {})
      params.require(:plant_type).permit(:name)
    end
end
