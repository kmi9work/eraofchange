class GameParametersController < ApplicationController
  before_action :set_game_parameter, only: %i[ show edit update destroy]

  # GET /game_parameters or /game_parameters.json
  def index
    @game_parameters = GameParameter.all
  end

  def pay_state_expenses
    GameParameter.pay_state_expenses
  end

  def unpay_state_expenses
    GameParameter.unpay_state_expenses
  end

  def increase_year
    GameParameter.increase_year(params[:kaznachei_bonus])
  end

  # GET /game_parameters/1 or /game_parameters/1.json
  def show
  end

  def show_schedule
    @time = GameParameter.show_schedule
  end

  def toggle_timer
    GameParameter.toggle_timer
  end

  # GET /game_parameters/new
  def new
    @game_parameter = GameParameter.new
  end

  # GET /game_parameters/1/edit
  def edit
  end

  # POST /game_parameters or /game_parameters.json
  def create
    @game_parameter = GameParameter.new(game_parameter_params)

    respond_to do |format|
      if @game_parameter.save
        format.html { redirect_to game_parameter_url(@game_parameter), notice: "Game parameter was successfully created." }
        format.json { render :show, status: :created, location: @game_parameter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game_parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /game_parameters/1 or /game_parameters/1.json
  def update
    respond_to do |format|
      if @game_parameter.update(game_parameter_params)
        format.html { redirect_to game_parameter_url(@game_parameter), notice: "Game parameter was successfully updated." }
        format.json { render :show, status: :ok, location: @game_parameter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game_parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_parameters/1 or /game_parameters/1.json
  def destroy
    @game_parameter.destroy

    respond_to do |format|
      format.html { redirect_to game_parameters_url, notice: "Game parameter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_parameter
      @game_parameter = GameParameter.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def game_parameter_params
      params.fetch(:game_parameter, {})
    end
end
