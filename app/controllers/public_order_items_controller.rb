class PublicOrderItemsController < ApplicationController
  before_action :set_public_order_item, only: %i[ show edit update destroy ]

  # GET /public_order_items or /public_order_items.json
  def index
    @public_order_items = PublicOrderItem.all
  end

  # GET /public_order_items/1 or /public_order_items/1.json
  def show
  end

  # GET /public_order_items/new
  def new
    @public_order_item = PublicOrderItem.new
  end

  # GET /public_order_items/1/edit
  def edit
  end

  # POST /public_order_items or /public_order_items.json
  def create
    @public_order_item = PublicOrderItem.new(public_order_item_params)

    respond_to do |format|
      if @public_order_item.save
        format.html { redirect_to public_order_item_url(@public_order_item), notice: "Public order item was successfully created." }
        format.json { render :show, status: :created, location: @public_order_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @public_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /public_order_items/1 or /public_order_items/1.json
  def update
    respond_to do |format|
      if @public_order_item.update(public_order_item_params)
        format.html { redirect_to public_order_item_url(@public_order_item), notice: "Public order item was successfully updated." }
        format.json { render :show, status: :ok, location: @public_order_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @public_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_order_items/1 or /public_order_items/1.json
  def destroy
    @public_order_item.destroy

    respond_to do |format|
      format.html { redirect_to public_order_items_url, notice: "Public order item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_public_order_item
      @public_order_item = PublicOrderItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def public_order_item_params
      params.require(:public_order_item).permit(:value, :region_id, :entity_id, :entity_type, :comment, :year)
    end
end
