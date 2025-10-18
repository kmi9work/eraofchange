class CaravansController < ApplicationController
  before_action :set_caravan, only: %i[ show edit update destroy ]

  def register_caravan
    result = Caravan.register_caravan(register_caravan_params)
    
    if result[:success]
      render json: { message: 'Caravan registered successfully', caravan: result[:caravan] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /caravans or /caravans.json
  def index
    @caravans = Caravan.all
  end

  # GET /caravans/1 or /caravans/1.json
  def show
  end

  # GET /caravans/new
  def new
    @caravan = Caravan.new
  end

  # GET /caravans/1/edit
  def edit
  end

  # POST /caravans or /caravans.json
  def create
    @caravan = Caravan.new(caravan_params)

    respond_to do |format|
      if @caravan.save
        format.html { redirect_to caravan_url(@caravan), notice: "Caravan was successfully created." }
        format.json { render :show, status: :created, location: @caravan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @caravan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caravans/1 or /caravans/1.json
  def update
    respond_to do |format|
      if @caravan.update(caravan_params)
        format.html { redirect_to caravan_url(@caravan), notice: "Caravan was successfully updated." }
        format.json { render :show, status: :ok, location: @caravan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @caravan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /caravans/1 or /caravans/1.json
  def destroy
    @caravan.destroy

    respond_to do |format|
      format.html { redirect_to caravans_url, notice: "Caravan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caravan
      @caravan = Caravan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def caravan_params
      params.require(:caravan).permit(:title, :body)
    end
    
    def register_caravan_params
      params.permit(:country_id, :purchase_cost, :sale_income, incoming: [:identificator, :name, :count], outcoming: [:identificator, :name, :count])
    end
end
