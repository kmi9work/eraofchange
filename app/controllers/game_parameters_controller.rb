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
    # create_schedule автоматически использует default_schedule из ядра или плагина
    GameParameter.create_schedule
    render json: { success: true, message: "Расписание создано" }
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

  def shift_schedule
    result = GameParameter.shift_schedule(params[:request])
    render json: result
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def plugin_status
    # Проверка статуса плагинов
    begin
      country_extensions_loaded = Country.included_modules.include?(VassalsAndRobbers::Concerns::CountryExtensions)
    rescue
      country_extensions_loaded = false
    end
    
    status = {
      active_game: ENV['ACTIVE_GAME'] || 'not set',
      alliances_enabled: Country.alliances_enabled,
      country_extensions_loaded: country_extensions_loaded,
      env_file_exists: File.exist?(Rails.root.join('.env.production')),
      env_file_content: File.exist?(Rails.root.join('.env.production')) ? File.read(Rails.root.join('.env.production')).strip : 'not found'
    }
    render json: status
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
   sort_by = params[:sort_by] || :capital
   @game_results = GameParameter.show_sorted_results(sort_by: sort_by)
   render json: @game_results
  end  

  def show_noble_results
   @noble_results = GameParameter.show_noble_results
   render json: @noble_results

  end

  def display_results
   @current_display = GameParameter.display_results
   render json: @current_display
  end

  # Объединённый ответ для экрана: текущий подэкран, результаты купцов и знати
  def screen_bundle
    # Определяем тип сортировки из display параметра
    display = GameParameter.display_results.to_s
    sort_by = :capital # По умолчанию по капиталу
    
    # Если экран связан с боярскими милостями, используем соответствующую сортировку
    if display.include?('Boyar')
      if display.include?('WithCapital')
        sort_by = :boyar_favor_with_capital
      else
        sort_by = :boyar_favor
      end
    end
    
    merchants = GameParameter.show_sorted_results(sort_by: sort_by)
    nobles   = GameParameter.show_noble_results
    settings = GameParameter.get_merchant_results_settings

    render json: {
      display: display,
      merchants: merchants,
      nobles: nobles,
      show_cap_per_player: settings[:show_cap_per_player]
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end


  def change_results_display
    GameParameter.change_results_display(params[:request])
  end

  def get_merchant_results_settings
    settings = GameParameter.get_merchant_results_settings
    render json: settings
  end

  def update_merchant_results_settings
    GameParameter.update_merchant_results_settings(params.permit(:show_cap_per_player).to_h.symbolize_keys)
    render json: { success: true, message: "Настройки обновлены" }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def get_years_count
    years_count = GameParameter.get_years_count
    render json: { years_count: years_count }
  end

  def get_active_lingering_effects
    year = params[:year]&.to_i || GameParameter.current_year
    effects = GameParameter.get_active_lingering_effects(year)
    render json: { 
      year: year,
      effects: effects,
      count: effects.length
    }
  end

  def update_years_count
    years_count = params[:years_count].to_i
    result = GameParameter.update_years_count(years_count)
    render json: result
  end

  def get_caravan_robbery_settings
    settings = GameParameter.get_caravan_robbery_settings
    render json: settings
  end

  def update_caravan_robbery_settings
    result = GameParameter.update_caravan_robbery_settings(params.permit(:robbery_by_year => {}, :protected_guilds_by_year => {}).to_h.symbolize_keys)
    render json: result
  end

  def get_caravans_per_guild
    caravans_per_guild = GameParameter.get_caravans_per_guild
    render json: { caravans_per_guild: caravans_per_guild }
  end

  def update_caravans_per_guild
    caravans_per_guild = params[:caravans_per_guild].to_i
    result = GameParameter.update_caravans_per_guild(caravans_per_guild)
    render json: result
  end

  def get_robbery_stats
    stats = GameParameter.get_robbery_stats_for_current_year
    render json: stats
  end

  # GET /game_parameters/get_vassalage_settings
  def get_vassalage_settings
    vassalage_settings = GameParameter.find_by(identificator: "vassalage_settings")
    if vassalage_settings && vassalage_settings.params
      render json: vassalage_settings.params
    else
      render json: { vassal_incomes: {} }
    end
  end

  # PATCH /game_parameters/update_vassalage_settings
  def update_vassalage_settings
    vassalage_settings = GameParameter.find_or_create_by(identificator: "vassalage_settings") do |gp|
      gp.name = "Настройки вассалитета"
      gp.value = "1"
    end
    
    vassalage_settings.params ||= {}
    vassalage_settings.params['vassal_incomes'] = params[:vassal_incomes] || {}
    vassalage_settings.save!
    
    render json: { success: true, message: "Настройки вассалитета обновлены" }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
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
    params.fetch(:game_parameter, {}).permit(:name, :identificator, :value, params: {})
  end
end
