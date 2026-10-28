class GameParametersController < ApplicationController
  before_action :set_game_parameter, only: %i[ show edit update destroy]

  # GET /game_parameters or /game_parameters.json
  def index
    @game_parameters = GameParameter.all
  end

  def pay_state_expenses
    result = GameParameter.pay_state_expenses(results_country)
    render json: result
  end

  def unpay_state_expenses
    result = GameParameter.unpay_state_expenses(results_country)
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
    # create_schedule автоматически использует default_schedule из ядра или плагина.
    # Если передан preset — применяем сохранённый пресет вместо встроенного расписания.
    preset = params.dig(:request, :preset) || params[:preset]
    if preset.present? && preset.to_s != GameParameter::SCHEDULE_PRESET_DEFAULT
      result = GameParameter.apply_schedule_preset(preset)
      return render json: result.merge(message: "Расписание создано из пресета '#{result[:name]}'")
    end

    GameParameter.create_schedule
    render json: { success: true, message: "Расписание создано" }
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def schedule_presets
    render json: { success: true, presets: GameParameter.schedule_presets,
                   dir: GameParameter.schedule_presets_dir.to_s }
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def save_schedule_preset
    name = params.dig(:request, :name) || params[:name]
    result = GameParameter.save_schedule_preset(name)
    render json: result.merge(message: "Пресет '#{result[:name]}' сохранён")
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def apply_schedule_preset
    slug = params.dig(:request, :slug) || params[:slug]
    result = GameParameter.apply_schedule_preset(slug)
    render json: result.merge(message: "Расписание создано из пресета '#{result[:name]}'")
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def delete_schedule_preset
    slug = params.dig(:request, :slug) || params[:slug]
    result = GameParameter.delete_schedule_preset(slug)
    render json: result.merge(message: "Пресет '#{result[:slug]}' удалён")
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
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

  def show_sovereign_schedule
    render json: GameParameter.show_sovereign_schedule
  end

  def create_sovereign_schedule
    GameParameter.create_sovereign_schedule
    render json: { success: true, message: "Расписание Государя создано" }
  end

  def update_sovereign_schedule_name
    GameParameter.update_sovereign_schedule_name(params[:request])
  end

  def add_sovereign_schedule_item
    GameParameter.add_sovereign_schedule_item(params[:request])
  end

  def update_sovereign_schedule_item
    GameParameter.update_sovereign_schedule_item(params[:request])
  end

  def delete_sovereign_schedule_item
    GameParameter.delete_sovereign_schedule_item(params[:request])
  end

  def shift_sovereign_schedule
    result = GameParameter.shift_sovereign_schedule(params[:request])
    render json: result
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
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

  # PATCH /game_parameters/clear_results — без country_id чистит все государства
  # (для главного мастера), с country_id — только указанное
  def clear_results
    country = params[:country_id].present? ? Country.find_by(id: params[:country_id]) : nil
    GameParameter.clear_results(country)
    render json: { success: true, country_id: country&.id }
  end

  def show_sorted_results
   country = results_country
   if snapshot_requested?
     snapshot = snapshot_payload
     return render json: snapshot if snapshot
   end

   sort_by = params[:sort_by] || :capital
   @game_results = GameParameter.show_sorted_results(sort_by: sort_by, country: country)
   render json: {
     country_id: country&.id,
     year: GameParameter.current_year,
     source: 'live',
     results: @game_results
   }
  end  

  def show_noble_results
   country = results_country
   if snapshot_requested?
     snapshot = snapshot_payload
     return render json: snapshot.slice(:year, :country_id, :source, :nobles, :closed_at).merge(results: snapshot[:nobles]) if snapshot
   end

   @noble_results = GameParameter.show_noble_results(country)
   render json: {
     country_id: country&.id,
     year: GameParameter.current_year,
     source: 'live',
     results: @noble_results
   }
  end

  def display_results
   @current_display = GameParameter.display_results(results_country)
   render json: @current_display
  end

  # Объединённый ответ для экрана: текущий подэкран, результаты купцов и знати
  def screen_bundle
    country = results_country
    if snapshot_requested?
      snapshot = snapshot_payload
      return render json: snapshot if snapshot
    end

    # Определяем тип сортировки из display параметра
    display = GameParameter.display_results(country).to_s
    sort_by = :capital # По умолчанию по капиталу
    
    # Если экран связан с боярскими милостями, используем соответствующую сортировку
    if display.include?('Boyar')
      if display.include?('WithCapital')
        sort_by = :boyar_favor_with_capital
      else
        sort_by = :boyar_favor
      end
    end
    
    merchants = GameParameter.show_sorted_results(sort_by: sort_by, country: country)
    nobles   = GameParameter.show_noble_results(country)
    settings = GameParameter.get_merchant_results_settings(country)

    render json: {
      display: display,
      country_id: country&.id,
      year: GameParameter.current_year,
      source: 'live',
      merchants: merchants,
      nobles: nobles,
      show_cap_per_player: settings[:show_cap_per_player],
      intelligence_data_status: settings[:intelligence_data_status]
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end


  def change_results_display
    GameParameter.change_results_display(params[:request], results_country)
  end

  def get_merchant_results_settings
    settings = GameParameter.get_merchant_results_settings(results_country)
    render json: settings
  end

  def update_merchant_results_settings
    payload = params.permit(
      :show_cap_per_player,
      intelligence_data_status: [
        :military_recruitment,
        :scientists_recruitment,
        :teaching_staff_recruitment
      ]
    ).to_h
    GameParameter.update_merchant_results_settings(payload.deep_symbolize_keys, results_country)
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

  def get_max_relations_for_trade_points
    max_relations = GameParameter.get_max_relations_for_trade_points
    render json: { max_relations_for_trade_points: max_relations }
  end

  def update_max_relations_for_trade_points
    max_relations = params[:max_relations_for_trade_points].to_i
    result = GameParameter.update_max_relations_for_trade_points(max_relations)
    render json: result
  end

  # GET /game_parameters/get_max_plants_per_guild
  def get_max_plants_per_guild
    max_plants_per_guild = GameParameter.get_max_plants_per_guild
    render json: { max_plants_per_guild: max_plants_per_guild }
  end

  # PATCH /game_parameters/update_max_plants_per_guild
  def update_max_plants_per_guild
    value = params[:max_plants_per_guild].to_i
    result = GameParameter.update_max_plants_per_guild(value)
    render json: result
  end

  # GET /game_parameters/get_vassalage_settings
  # ?country_id=<id> — суммы вассалов указанного сюзерена (по умолчанию — текущего).
  # Ответ содержит и плоский срез сюзерена (vassal_incomes), и полную карту по
  # сюзеренам (by_sovereign), чтобы экран не смешивал настройки команд (ТЗ № 2, § 7.2).
  def get_vassalage_settings
    vassalage_settings = GameParameter.find_by(identificator: "vassalage_settings")
    stored = vassalage_settings&.params&.dig("vassal_incomes") || {}
    sovereign = results_country
    scoped = vassalage_incomes_for(stored, sovereign)

    render json: {
      country_id: sovereign&.id,
      country: sovereign&.name,
      vassal_incomes: scoped,
      by_sovereign: stored.is_a?(Hash) ? stored : {}
    }
  end

  # PATCH /game_parameters/update_vassalage_settings
  # ?country_id=<id> — записывает суммы только этого сюзерена, настройки остальных
  # государств сохраняются (иначе правка одной команды стирала бы чужую).
  def update_vassalage_settings
    vassalage_settings = GameParameter.find_or_create_by(identificator: "vassalage_settings") do |gp|
      gp.name = "Настройки вассалитета"
      gp.value = "1"
    end

    vassalage_settings.params ||= {}
    sovereign = results_country
    stored = vassalage_settings.params['vassal_incomes'] || {}
    incoming = params[:vassal_incomes] || {}

    # Полная карта по сюзеренам: пишем только срез запрошенного государства
    if params[:by_sovereign].present?
      vassalage_settings.params['vassal_incomes'] = params[:by_sovereign].to_unsafe_h
    else
      vassalage_settings.params['vassal_incomes'] = store_vassalage_incomes(stored, sovereign, incoming)
    end

    vassalage_settings.save!

    render json: { success: true, message: "Настройки вассалитета обновлены", country_id: sovereign&.id }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # Срез сумм вассалов сюзерена с поддержкой обоих форматов params['vassal_incomes']
  # (плоский — «до перехода», относился к «Руси»; вложенный — по сюзеренам)
  def vassalage_incomes_for(stored, sovereign)
    stored = {} unless stored.is_a?(Hash)
    if defined?(VassalsAndRobbers::VassalageSettings)
      VassalsAndRobbers::VassalageSettings.incomes_for(stored, sovereign)
    else
      scoped = stored[sovereign&.id.to_s]
      scoped.is_a?(Hash) ? scoped : {}
    end
  end

  # Запись сумм сюзерена с сохранением настроек остальных государств
  def store_vassalage_incomes(stored, sovereign, incomes)
    stored = {} unless stored.is_a?(Hash)
    return stored if sovereign.nil?

    if defined?(VassalsAndRobbers::VassalageSettings)
      VassalsAndRobbers::VassalageSettings.store_incomes(stored, sovereign, incomes)
    else
      base = stored.dup
      base[sovereign.id.to_s] = incomes || {}
      base
    end
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

    # Сквозные параметры результатов: государство (?country_id=) и год (?year=).
    # Снимок года отдаётся, если для этого года и государства он есть (source: snapshot).
    def snapshot_requested?
      params[:year].present?
    end

    def results_country
      return Country.current if params[:country_id].blank?

      Country.find_by(id: params[:country_id]) || Country.current
    end

    def snapshot_payload
      country = results_country
      snapshot = GameParameter.results_for_year(params[:year], country)
      return nil if snapshot.nil?

      {
        year: params[:year].to_i,
        country_id: country&.id,
        source: 'snapshot',
        display: GameParameter.display_results(country),
        nobles: snapshot['nobles'] || [],
        merchants: snapshot['merchants'] || [],
        closed_at: snapshot['closed_at']
      }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_game_parameter
      @game_parameter = GameParameter.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
  def game_parameter_params
    params.fetch(:game_parameter, {}).permit(:name, :identificator, :value, params: {})
  end
end
