class GameParametersController < ApplicationController
  before_action :set_game_parameter, only: %i[ show edit update destroy]

  # GET /game_parameters or /game_parameters.json
  def index
    @game_parameters = GameParameter.all
  end

  def pay_state_expenses
    result = GameParameter.pay_state_expenses
    render json: result
  end

  def unpay_state_expenses
    result = GameParameter.unpay_state_expenses
    render json: result
  end

  def increase_year
    old_year = GameParameter.current_year
    result = GameParameter.increase_year(params[:kaznachei_bonus])
    new_year = GameParameter.current_year
    
    # Создаем аудит для смены года
    current_year_param = GameParameter.find_by(identificator: "current_year")
    current_year_param.audits.create!(
      action: 'update',
      auditable: current_year_param,
      user: current_user,
      audited_changes: { 'value' => [old_year.to_s, new_year.to_s] },
      comment: "Год изменен с #{old_year} на #{new_year}"
    )
    
    render json: result
  end

  # GET /game_parameters/1 or /game_parameters/1.json
  def show
  end

  def create_schedule
    GameParameter.create_temp_schedule
  end

  def show_schedule
    @time = GameParameter.show_schedule
  end

  def add_schedule_item
    GameParameter.add_schedule_item(params[:request])
  end

  def delete_schedule_item
    GameParameter.delete_schedule_item(params[:request])
  end

  def update_schedule_item
    GameParameter.update_schedule_item(params[:request])
  end

  def toggle_screen
    GameParameter.toggle_screen(params[:request])
  end

  def get_screen
    @screen = GameParameter.get_screen
    render json: @screen
  end

  def toggle_timer
    GameParameter.toggle_timer(params[:request])
  end

 def save_sorted_results
    GameParameter.sort_and_save_results(params[:request].to_unsafe_h)
  end

  def update_results
    GameParameter.update_results(params[:request].to_unsafe_h)
  end

  def delete_result
    GameParameter.delete_result(params[:request].to_unsafe_h)
  end

  def show_sorted_results
   @game_results = GameParameter.show_sorted_results
   render json: @game_results
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
