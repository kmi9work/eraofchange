class TechnologyItemsController < ApplicationController
  before_action :set_technology_item, only: %i[ show edit update destroy ]

  # GET /technology_items or /technology_items.json
  def index
    @technology_items = TechnologyItem.all
  end

  # GET /technology_items/1 or /technology_items/1.json
  def show
  end

  # GET /technology_items/new
  def new
    @technology_item = TechnologyItem.new
  end

  # GET /technology_items/1/edit
  def edit
  end

  # POST /technology_items or /technology_items.json
  def create
    @technology_item = TechnologyItem.new(technology_item_params)

    respond_to do |format|
      if @technology_item.save
        format.html { redirect_to technology_item_url(@technology_item), notice: "Technology item was successfully created." }
        format.json { render :show, status: :created, location: @technology_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @technology_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /technology_items/1 or /technology_items/1.json
  def update
    respond_to do |format|
      if @technology_item.update(technology_item_params)
        format.html { redirect_to technology_item_url(@technology_item), notice: "Technology item was successfully updated." }
        format.json { render :show, status: :ok, location: @technology_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @technology_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technology_items/1 or /technology_items/1.json
  def destroy
    @technology_item.destroy

    respond_to do |format|
      format.html { redirect_to technology_items_url, notice: "Technology item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_technology_item
      @technology_item = TechnologyItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def technology_item_params
      params.require(:technology_item).permit(:value, :technology_id, :entity_id, :entity_type, :comment, :year)
    end
end
