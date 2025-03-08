class InfluenceItemsController < ApplicationController
  before_action :set_influence_item, only: %i[ show edit update destroy ]

  # GET /influence_items or /influence_items.json
  def index
    @influence_items = InfluenceItem.all
  end

  # GET /influence_items/1 or /influence_items/1.json
  def show
  end

  # GET /influence_items/new
  def new
    @influence_item = InfluenceItem.new
  end

  # GET /influence_items/1/edit
  def edit
  end

  # POST /influence_items or /influence_items.json
  def create
    @influence_item = InfluenceItem.new(influence_item_params)

    respond_to do |format|
      if @influence_item.save
        format.html { redirect_to influence_item_url(@influence_item), notice: "Influence item was successfully created." }
        format.json { render :show, status: :created, location: @influence_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @influence_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /influence_items/1 or /influence_items/1.json
  def update
    respond_to do |format|
      if @influence_item.update(influence_item_params)
        format.html { redirect_to influence_item_url(@influence_item), notice: "Influence item was successfully updated." }
        format.json { render :show, status: :ok, location: @influence_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @influence_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /influence_items/1 or /influence_items/1.json
  def destroy
    @influence_item.destroy

    respond_to do |format|
      format.html { redirect_to influence_items_url, notice: "Influence item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_influence_item
      @influence_item = InfluenceItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def influence_item_params
      params.require(:influence_item).permit(:value, :player_id, :entity_id, :entity_type, :comment, :year)
    end
end
