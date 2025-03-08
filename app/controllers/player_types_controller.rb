class PlayerTypesController < ApplicationController
  before_action :set_player_type, only: %i[ show edit update destroy ]

  # GET /player_types or /player_types.json
  def index
    @player_types = PlayerType.all
  end

  # GET /player_types/1 or /player_types/1.json
  def show
  end

  # GET /player_types/new
  def new
    @player_type = PlayerType.new
  end

  # GET /player_types/1/edit
  def edit
  end

  # POST /player_types or /player_types.json
  def create
    @player_type = PlayerType.new(player_type_params)

    respond_to do |format|
      if @player_type.save
        format.html { redirect_to player_type_url(@player_type), notice: "Player type was successfully created." }
        format.json { render :show, status: :created, location: @player_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /player_types/1 or /player_types/1.json
  def update
    respond_to do |format|
      if @player_type.update(player_type_params)
        format.html { redirect_to player_type_url(@player_type), notice: "Player type was successfully updated." }
        format.json { render :show, status: :ok, location: @player_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /player_types/1 or /player_types/1.json
  def destroy
    @player_type.destroy

    respond_to do |format|
      format.html { redirect_to player_types_url, notice: "Player type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player_type
      @player_type = PlayerType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_type_params
      params.require(:player_type).permit(:name, :player_ids => [])
    end
end
