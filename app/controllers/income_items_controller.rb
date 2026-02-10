class IncomeItemsController < ApplicationController
  before_action :set_income_item, only: %i[show edit update destroy]

  # GET /income_items or /income_items.json
  def index
    @income_items = IncomeItem.includes(:player, :entity)
  end

  # GET /income_items/1 or /income_items/1.json
  def show
  end

  # GET /income_items/new
  def new
    @income_item = IncomeItem.new
  end

  # GET /income_items/1/edit
  def edit
  end

  # POST /income_items or /income_items.json
  def create
    @income_item = IncomeItem.new(income_item_params)

    respond_to do |format|
      if @income_item.save
        format.html { redirect_to income_item_url(@income_item), notice: "Income item was successfully created." }
        format.json { render :show, status: :created, location: @income_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @income_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /income_items/1 or /income_items/1.json
  def update
    respond_to do |format|
      if @income_item.update(income_item_params)
        format.html { redirect_to income_item_url(@income_item), notice: "Income item was successfully updated." }
        format.json { render :show, status: :ok, location: @income_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @income_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /income_items/1 or /income_items/1.json
  def destroy
    @income_item.destroy

    respond_to do |format|
      format.html { redirect_to income_items_url, notice: "Income item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_income_item
    @income_item = IncomeItem.find(params[:id])
  end

  def income_item_params
    params.require(:income_item).permit(:value, :player_id, :entity_id, :entity_type, :comment, :year)
  end
end

