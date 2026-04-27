class PlantCategoriesController < ApplicationController
  before_action :set_plant_category, only: %i[ show edit update destroy ]

  # GET /plant_categories or /plant_categories.json
  def index
    @plant_categories = PlantCategory.all
  end

  # GET /plant_categories/1 or /plant_categories/1.json
  def show
  end

  # GET /plant_categories/new
  def new
    @plant_category = PlantCategory.new
  end

  # GET /plant_categories/1/edit
  def edit
  end

  # POST /plant_categories or /plant_categories.json
  def create
    @plant_category = PlantCategory.new(plant_category_params)

    respond_to do |format|
      if @plant_category.save
        format.html { redirect_to plant_category_url(@plant_category), notice: "Plant category was successfully created." }
        format.json { render :show, status: :created, location: @plant_category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plant_categories/1 or /plant_categories/1.json
  def update
    respond_to do |format|
      if @plant_category.update(plant_category_params)
        format.html { redirect_to plant_category_url(@plant_category), notice: "Plant category was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plant_categories/1 or /plant_categories/1.json
  def destroy
    @plant_category.destroy

    respond_to do |format|
      format.html { redirect_to plant_categories_url, notice: "Plant category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant_category
      @plant_category = PlantCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plant_category_params
      params.fetch(:plant_category).permit(:name, :plant_type_ids => [], :plant_place_ids => [])
    end
end

