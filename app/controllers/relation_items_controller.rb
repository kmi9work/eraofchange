class RelationItemsController < ApplicationController
  before_action :set_relation_item, only: %i[ show edit update destroy ]

  # GET /relation_items or /relation_items.json
  def index
    @relation_items = RelationItem.all
  end

  # GET /relation_items/1 or /relation_items/1.json
  def show
  end

  # GET /relation_items/new
  def new
    @relation_item = RelationItem.new
  end

  # GET /relation_items/1/edit
  def edit
  end

  # POST /relation_items or /relation_items.json
  def create
    @relation_item = RelationItem.new(relation_item_params)

    respond_to do |format|
      if @relation_item.save
        format.html { redirect_to relation_item_url(@relation_item), notice: "Relation item was successfully created." }
        format.json { render :show, status: :created, location: @relation_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @relation_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /relation_items/1 or /relation_items/1.json
  def update
    respond_to do |format|
      if @relation_item.update(relation_item_params)
        format.html { redirect_to relation_item_url(@relation_item), notice: "Relation item was successfully updated." }
        format.json { render :show, status: :ok, location: @relation_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @relation_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relation_items/1 or /relation_items/1.json
  def destroy
    @relation_item.destroy

    respond_to do |format|
      format.html { redirect_to relation_items_url, notice: "Relation item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relation_item
      @relation_item = RelationItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def relation_item_params
      params.require(:relation_item).permit(:value, :country_id, :entity_id, :entity_type, :comment, :year)
    end
end
