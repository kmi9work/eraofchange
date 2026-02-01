class GameParameter < ApplicationRecord
  audited if: :should_audit?

  private

  def should_audit?
    # Аудит только для current_year (изменение года и оплата госрасходов)
    return false unless identificator == "current_year"
    
    # Проверяем, что изменились нужные поля
    value_changed? || (params_changed? && state_expenses_changed?)
  end

  def state_expenses_changed?
    return false unless params_changed?
    
    old_params = params_was || {}
    new_params = params || {}
    
    old_params['state_expenses'] != new_params['state_expenses']
  end

  def audit_comment
    case identificator
    when "current_year"
      if params_changed? && params_change[1]
        new_params = params_change[1]
        old_params = params_change[0] || {}
        
        if new_params["state_expenses"] == true && old_params["state_expenses"] == false
          "Оплачены госрасходы за #{value} год"
        elsif new_params["state_expenses"] == false && old_params["state_expenses"] == true
          "Отменена оплата госрасходов за #{value} год"
        end
      elsif value_changed?
        "Год изменен с #{value_change[0]} на #{value_change[1]}"
      end
    end
  end



  TIMER = 4
  SCREEN = 5
  DEFAULT_SCREEN = "placeholder"
  RESULTS = 6
  LINGERING_EFFECTS = "lingering_effects"
  MOBILE_HELPER = "mobile_helper"

  NO_STATE_EXPENSES = -5
  NOT_TICKING = 0
  
  # Автоматический запуск следующего цикла таймера (можно переопределить в плагинах)
  # true - следующий цикл запускается автоматически
  # false - следующий цикл запускается по кнопке (базовая игра)
  class_attribute :auto_start_next_cycle, default: false

  def self.show_mobile_helper
    g_p = GameParameter.find_by(identificator: MOBILE_HELPER)
    return g_p.value
  end

  def self.toggle_helper
    g_p = GameParameter.find_by(identificator: MOBILE_HELPER)
    g_p.value = (g_p.value.to_i - 1).abs
    g_p.save    
  end

  SCHEDULE = [
            {id: 1, identificator: "Регистрация игроков", start: "10:30", finish: "11:00", type: "play"},
            {id: 2, identificator: "Инструктаж", start: "11:00",  finish: "11:30", type: "pause"},
            {id: 3, identificator: "Первый цикл", start: "11:30",  finish: "13:00", type: "play"},
            {id: 4, identificator: "Второй цикл", start: "13:00",  finish: "14:00", type: "play"},
            {id: 5, identificator: "Обед", start:"14:00",    finish: "14:30", type: "pause"},
            {id: 6, identificator: "Третий цикл", start: "14:30",  finish: "15:30", type: "play"},              
            {id: 7, identificator: "Четвертый цикл", start: "15:30",  finish: "16:30", type: "play"},
            {id: 8, identificator: "Пятый цикл", start: "16:30",  finish: "17:30", type: "play"}
          ]

  # Метод для получения стандартного расписания (может быть переопределен в плагинах)
  def self.default_schedule
    SCHEDULE
  end

### 
def self.any_lingering_effects?(effect_name, year = GameParameter.current_year, target = nil)
  effects_param = GameParameter.find_by(identificator: LINGERING_EFFECTS)
  return false unless effects_param&.params

  effects_param.params.any? do |entry|
    effects = Array(entry["effects"]).map(&:to_s)
    has_effect = effects.include?(effect_name.to_s)
    next false unless has_effect

    is_year = Array(entry["duration"]).include?(year)
    next false unless is_year

    next true unless target

    targets_match?(entry["targets"], target)
  end
end

# Возвращает все активные эффекты для указанного года
def self.get_active_lingering_effects(year = GameParameter.current_year)
  effects_param = GameParameter.find_by(identificator: LINGERING_EFFECTS)
  return [] unless effects_param&.params
  
  active_effects = []
  
  effects_param.params.each do |entry|
    # Проверяем, активен ли эффект в указанном году
    if entry["duration"]&.include?(year)
      # Для каждого эффекта в массиве effects создаем отдельную запись
      effects_array = entry["effects"] || []
      effects_array.each do |effect|
        active_effects << {
          action: entry["name_of_action"],
          effect: effect,
          duration: entry["duration"],
          targets: serialize_targets_for_response(entry["targets"])
        }
      end
    end
  end
  
  active_effects
end

def self.register_lingering_effects(action, effects, years = GameParameter.current_year, targets = nil)
    duration = Array(years).flatten.compact.map do |value|
      if value.is_a?(String) && value.match?(/\A[+-]?\d+\z/)
        value.to_i
      else
        value
      end
    end.uniq

    g_p = GameParameter.find_by(identificator: LINGERING_EFFECTS)
    
    # Если записи нет, создаем её
    unless g_p
      Rails.logger.warn "[GameParameter] LINGERING_EFFECTS record not found, creating..."
      g_p = GameParameter.create!(identificator: LINGERING_EFFECTS, value: "0", params: [])
    end

    current_params = g_p.params || []
    
    effects_array = Array(effects).flatten.compact.map(&:to_s).uniq
    targets_array = normalize_targets_for_storage(targets)
    
    new_entry = {
      "duration" => duration, 
      "name_of_action" => action, 
      "effects" => effects_array,
      "targets" => targets_array
    }
    
    g_p.params = current_params + [new_entry]
    
    g_p.params_will_change!
    g_p.save
  end

def self.targets_match?(stored_targets, target)
  targets = Array(stored_targets)
  return false if targets.empty?

  normalized_requested = normalize_lookup_target(target)

  targets.any? do |stored_target|
    single_target_match?(stored_target, normalized_requested)
  end
end

def self.single_target_match?(stored_target, requested)
  stored_normalized = normalize_lookup_target(stored_target)

  stored_id = stored_normalized[:id]
  stored_name = stored_normalized[:name]
  stored_raw = stored_normalized[:raw]

  requested_id = requested[:id]
  requested_name = requested[:name]
  requested_raw = requested[:raw]

  id_match = stored_id && requested_id && stored_id.to_s == requested_id.to_s
  name_match = stored_name && requested_name && stored_name.to_s == requested_name.to_s
  raw_match = stored_raw.present? && requested_raw.present? && stored_raw.to_s == requested_raw.to_s

  id_match || name_match || raw_match
end

def self.normalize_lookup_target(target)
  if target.is_a?(Hash)
    hash = target.stringify_keys
    {
      id: extract_id_from_hash(hash),
      name: extract_name_from_hash(hash),
      raw: hash["raw"] || hash
    }
  elsif target.respond_to?(:id)
    {
      id: target.id,
      name: extract_name_from_object(target),
      raw: target
    }
  elsif numeric_string?(target)
    {
      id: target.to_i,
      name: nil,
      raw: target
    }
  elsif target.is_a?(Integer)
    {
      id: target,
      name: nil,
      raw: target
    }
  else
    {
      id: nil,
      name: target.present? ? target.to_s : nil,
      raw: target
    }
  end
end

def self.extract_id_from_hash(hash)
  candidates = [
    hash["id"],
    hash["guild_id"],
    hash["value_id"],
    hash["target_id"]
  ].compact

  candidates.each do |candidate|
    return candidate.to_i if numeric_string?(candidate) || candidate.is_a?(Integer)
  end

  nil
end

def self.extract_name_from_hash(hash)
  [
    hash["name"],
    hash["label"],
    hash["value"],
    hash["display"],
    hash["title"]
  ].compact.first&.to_s
end

def self.extract_name_from_object(object)
  if object.respond_to?(:name) && object.name.present?
    object.name
  elsif object.respond_to?(:label) && object.label.present?
    object.label
  elsif object.respond_to?(:title) && object.title.present?
    object.title
  else
    nil
  end
end

def self.normalize_targets_for_storage(raw_targets)
  return [] if raw_targets.nil?

  targets_list =
    if raw_targets.is_a?(Array)
      raw_targets
    elsif raw_targets.is_a?(Hash)
      [raw_targets]
    else
      [raw_targets]
    end

  targets_list.compact.map { |target| normalize_target_for_storage(target) }
end

def self.normalize_target_for_storage(target)
  if target.is_a?(Hash)
    hash = target.stringify_keys
    hash["type"] ||= default_target_type(hash)
    hash["name"] ||= extract_name_from_hash(hash)
    hash
  elsif target.respond_to?(:id)
    {
      "type" => target.class.name.split("::").last.underscore,
      "id" => target.id,
      "name" => extract_name_from_object(target)
    }.compact
  elsif target.is_a?(Integer)
    { "type" => "guild", "id" => target }
  elsif numeric_string?(target)
    { "type" => "guild", "id" => target.to_i }
  else
    {
      "type" => "custom",
      "name" => target.to_s
    }
  end
end

def self.default_target_type(hash)
  return hash["type"] if hash["type"].present?
  return "guild" if hash["id"].present? || hash["guild_id"].present?

  "custom"
end

def self.numeric_string?(value)
  value.is_a?(String) && value.match?(/\A[+-]?\d+\z/)
end

def self.serialize_targets_for_response(targets)
  normalize_targets_for_storage(targets).map do |target|
    target.is_a?(Hash) ? target.stringify_keys : target
  end
end

    ###Результаты
  def self.show_noble_results
    game_results = GameParameter.find(RESULTS)
    players = Player.where(player_type_id: PlayerType::NOBLE)
    nobles_inf = []
    nobles_inf = players.map do |player|
      {noble_name: player.name,
      noble_influence: player.influence}
    end
    sorted_nobles =  nobles_inf.sort_by { |hash| -hash[:noble_influence].to_i }

    place = 0
    previous_value = nil

    sorted_nobles.delete_if { |n| n[:noble_name] == PlayerType::REBEL_NAME && n[:noble_influence] == 0 }

    sorted_nobles.each do |result|
      current_value = result[:noble_influence]
      place += 1 if current_value != previous_value    
      result[:place] = place
      previous_value = current_value
    end

    return sorted_nobles
  end

  def self.display_results
   return GameParameter.find(RESULTS).params["display"]
  end

  def self.change_results_display(string)
    game_results = GameParameter.find(RESULTS)
    game_results.params["display"] = string 
    game_results.save
  end

  def self.get_merchant_results_settings
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params ||= {}
    {
      show_cap_per_player: game_results.params["show_cap_per_player"] != false # По умолчанию true
    }
  end

  def self.update_merchant_results_settings(settings)
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params ||= {}
    game_results.params["show_cap_per_player"] = settings[:show_cap_per_player] unless settings[:show_cap_per_player].nil?
    game_results.save
  end



  def self.sort_and_save_results(result_hash = nil)
    # Этот метод теперь не используется для ручного добавления,
    # так как данные собираются автоматически из гильдий
    # Но оставим для обратной совместимости
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params ||= {}
    game_results.params.transform_keys!(&:to_sym)
    
    if result_hash
      result_hash.transform_keys!(&:to_sym)
      guild_id = result_hash[:guild_id]
      
      if guild_id
        # Инициализируем хранилище для дополнительных данных гильдий
        game_results.params[:guild_extra_data] ||= {}
        game_results.params[:guild_extra_data].transform_keys!(&:to_sym)
        
        guild_id_sym = guild_id.to_s.to_sym
        game_results.params[:guild_extra_data][guild_id_sym] = {
          money: result_hash[:money].to_i || 0,
          boyar_favor: result_hash[:boyar_favor].to_i || 0
        }
      end
    end
    
    game_results.save
  end

  def self.sort_and_rank_results(results)
    per_pl_cap = GameParameter.find_cap_per_pl(results)
    sorted_results = per_pl_cap.sort_by { |hash| -hash[:cap_per_pl].to_i }
    place = 0
    previous_value = nil
    
    sorted_results.each do |result|
      current_value = result[:cap_per_pl]
      place += 1 if current_value != previous_value    
      result[:place] = place
      previous_value = current_value
    end

    sorted_results
  end

  def self.sort_and_rank_results_by_boyar_favor(results)
    # Добавляем капитал на игрока для полноты информации
    per_pl_cap = GameParameter.find_cap_per_pl(results)
    # Сортируем по боярским милостям (по убыванию)
    sorted_results = per_pl_cap.sort_by { |hash| -hash[:boyar_favor].to_i }
    place = 0
    previous_value = nil
    
    sorted_results.each do |result|
      current_value = result[:boyar_favor]
      place += 1 if current_value != previous_value    
      result[:place] = place
      previous_value = current_value
    end

    sorted_results
  end

  def self.find_cap_per_pl(results)    
    per_pl_cap = []
    results.map! {|par| par.transform_keys(&:to_sym)}
    results.each do |result|
      result.transform_keys!(&:to_sym) if result.is_a?(Hash)
      num_of_players = result[:number_of_players].to_i > 0 ? result[:number_of_players].to_i : 1
      capital = result[:capital].to_i
      result[:cap_per_pl] = capital/num_of_players

      per_pl_cap << result
    end

    return per_pl_cap
  end

  def self.update_results(result_hash)   
    result_hash.transform_keys!(&:to_sym) 
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params ||= {}
    game_results.params.transform_keys!(&:to_sym)
    
    # Инициализируем хранилище для дополнительных данных гильдий
    game_results.params[:guild_extra_data] ||= {}
    game_results.params[:guild_extra_data].transform_keys!(&:to_sym)
    
    guild_id = result_hash[:guild_id].to_s.to_sym
    
    # Сохраняем деньги и боярскую милость для гильдии
    game_results.params[:guild_extra_data][guild_id] = {
      money: result_hash[:money].to_i || 0,
      boyar_favor: result_hash[:boyar_favor].to_i || 0
    }
    
    game_results.save
  end

  def self.delete_result(result_hash)
    # Удаление дополнительных данных для гильдии (обнуление денег и боярской милости)
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params ||= {}
    game_results.params.transform_keys!(&:to_sym)
    result_hash.transform_keys!(&:to_sym)
    
    guild_id = result_hash[:guild_id]
    if guild_id
      game_results.params[:guild_extra_data] ||= {}
      game_results.params[:guild_extra_data].transform_keys!(&:to_sym)
      
      guild_id_sym = guild_id.to_s.to_sym
      # Удаляем данные гильдии (обнуляем)
      game_results.params[:guild_extra_data].delete(guild_id_sym)
    end
    
    game_results.save
  end

  def self.show_sorted_results(sort_by: :capital)
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params ||= {}
    game_results.params.transform_keys!(&:to_sym)
    
    # Инициализируем хранилище для дополнительных данных гильдий (деньги и боярская милость)
    guild_extra_data = game_results.params[:guild_extra_data] || {}
    guild_extra_data.transform_keys!(&:to_sym) if guild_extra_data.is_a?(Hash)
    
    # Собираем результаты по всем гильдиям
    results = []
    Guild.all.each do |guild|
      # Считаем стоимость предприятий (сумма deposit)
      plants_value = guild.plants.sum { |plant| plant.plant_level&.deposit.to_i || 0 }
      
      # Количество игроков в гильдии
      number_of_players = guild.players.count
      
    # Получаем дополнительные данные (деньги и боярская милость)
    # Проверяем как символ строки и как число (для обратной совместимости)
    guild_id_key = guild.id.to_s.to_sym
    guild_data = guild_extra_data[guild_id_key] || guild_extra_data[guild.id] || {}
    guild_data.transform_keys!(&:to_sym) if guild_data.is_a?(Hash)
      
      money = guild_data[:money].to_i || 0
      boyar_favor = guild_data[:boyar_favor].to_i || 0
      
      # Итоговый капитал = деньги + стоимость предприятий
      capital = money + plants_value
      
      results << {
        guild_id: guild.id,
        player: guild.name,
        capital: capital,
        plants_value: plants_value,
        money: money,
        number_of_players: number_of_players > 0 ? number_of_players : 1,
        boyar_favor: boyar_favor
      }
    end
    
    # Сортируем и ранжируем в зависимости от параметра
    case sort_by.to_sym
    when :boyar_favor
      sorted_results = GameParameter.sort_and_rank_results_by_boyar_favor(results)
    when :boyar_favor_with_capital
      # Комбинированный вывод: сортируем по боярским милостям, но показываем и капитал
      sorted_results = GameParameter.sort_and_rank_results_by_boyar_favor(results)
    else
      # По умолчанию сортируем по капиталу
      sorted_results = GameParameter.sort_and_rank_results(results)
    end
    
    sorted_results
  end  

  def self.clear_results
    game_results = GameParameter.find_by(identificator: "results")
    game_results.params = []
    game_results.save
  end

###Управление экраном
  def self.toggle_screen(screen_value)
    screen = GameParameter.find_by(identificator: "screen")
    screen.value = screen_value
    screen.save 
  end

  def self.get_screen
    return GameParameter.find_by(identificator: "screen").value
  end

###Таймер и расписание

  def self.show_schedule
    timer = GameParameter.find_by(identificator: "schedule")
    schedule_item = {}
    id = 0
    schedule = timer.params.map do |item|
        id += 1
        { id: id,
          identificator: item["identificator"].to_s,
          start: item["start"],
          unix_start: GameParameter.modify_date(item["start"]),
          finish: item["finish"],
          unix_finish: GameParameter.modify_date(item["finish"]),
          type: item["type"] || "play"
        }
    end
    
    return {
      schedule: schedule, 
      ticking: timer.value,
      auto_start_next_cycle: self.auto_start_next_cycle
    }
  end

  def self.add_schedule_item(schedule_item)
    schedule_item.transform_keys(&:to_sym)
    timer = GameParameter.find_by(identificator: "schedule")
    params = timer.params
    last_id = params.present? ? params.last["id"]  : 0
    new_item   = {id: last_id + 1,
                  identificator: schedule_item[:identificator],
                  start: schedule_item[:start],
                  finish: schedule_item[:finish],
                  type: schedule_item[:type] || "play"
                }
    timer.params << new_item
    timer.save
  end

  def self.update_schedule_item(schedule_item)
    timer = GameParameter.find_by(identificator: "schedule")
    new_schedule = timer.params.map{|item| item["id"] == schedule_item["id"] ? schedule_item : item}
    timer.params = new_schedule
    timer.save
  end

  def self.delete_schedule_item(schedule_item_id)
    timer = GameParameter.find_by(identificator: "schedule")
    timer.params.delete_if {|item| item["id"] == schedule_item_id["id"]}
    timer.save
  end

  def self.create_temp_schedule
    dummy_schedule = []
    minutes_to_add = 1

    current_time = Time.now + (minutes_to_add * 60)
    item_name = 1 
    30.times do | item |
      dummy_schedule_item = {}
      dummy_schedule_item[:id] = item_name
      dummy_schedule_item[:identificator] = "Цикл #{item_name}"
      dummy_schedule_item[:start]  = current_time.strftime("%H:%M")
      current_time += (minutes_to_add * 60)
      dummy_schedule_item[:finish] = current_time.strftime("%H:%M")
      # Чередуем play и pause
      dummy_schedule_item[:type] = item_name.odd? ? "play" : "pause"
      item_name += 1
      dummy_schedule.push(dummy_schedule_item)
    end

    GameParameter.create_schedule(dummy_schedule)
  end

  def self.toggle_timer(value = nil)  
    timer = GameParameter.find_by(identificator: "schedule")
    timer.value = value.to_i              unless value.nil?
    timer.value = 1-timer.value.to_i      if     value.nil?
    timer.save
  end

  def self.modify_date(time_stringified)
    date = Time.zone.today.strftime
    date += " #{time_stringified}"
    time =  Time.strptime(date, "%Y-%m-%d %H:%M")
    unix_time = time.to_i
    return unix_time
  end

  def self.create_schedule(schedule = nil)
    timer = GameParameter.find_by(identificator: "schedule")
    timer.value = NOT_TICKING 
    timer.params = []
    
    # Если расписание не передано, используем default_schedule (может быть переопределен в плагинах)
    timer.params = schedule || default_schedule
    
    timer.save
  end

  ############

  def self.increase_year(kaznachei_bonus = 0) #Переводит в следующий год
    current_year = GameParameter.find_by(identificator: "current_year")
    if current_year.params["state_expenses"] == false
      PublicOrderItem.add(NO_STATE_EXPENSES, "Не оплачены расходы", nil, nil)
    else
      if kaznachei_bonus
        Job.find_by_id(Job::KAZNACHEI).players.each do |player|
          player.modify_influence(Job::KAZNACHEI_BONUS, "Бонус за оплату государства", current_year) 
        end
      end
    end
    Building.joins(:building_level).where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).each do |building|
      if !building.is_paid and !building.fined
        building.fine
      end
    end

    # Сбрасываем счетчики ограблений караванов при смене года
    reset_caravan_robbery_counters(self.current_year + 1)

    current_year.value = (self.current_year  + 1).to_s
    current_year.params["state_expenses"] = false
    current_year.save

    Player.all.each do |player|
      if player.params['income_taken']
        player.params['income_taken'] = false
        player.save
      end
    end
    if current_year.value.to_i == 3
      a = Army.create(name: 'Литва 3', settlement: Settlement.find_by_name('Киев'), owner: Country.find_by_name('Великое княжество Литовское'), owner_type: 'Country', params: {"paid" =>[], "palsy" => []})
      Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
      Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
      Troop.create(troop_type_id: 4, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

      a = Army.create(name: 'Орда 3', settlement: Settlement.find_by_name('Сарай-Берке'), owner: Country.find_by_name('Большая Орда'), owner_type: 'Country', params: {"paid" =>[], "palsy" => []})
      Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
      Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
      Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
    end

    return {msg: "Наступил следующий год"}
  end

  def self.current_year #показывает номер года
    GameParameter.find_by(identificator: "current_year")&.value&.to_i
  end

  def self.pay_state_expenses
    st_exp = self.find_by(identificator: "current_year")
    st_exp.params["state_expenses"] = true #Делает отметку о том, что в текущем году расходы оплачены
    st_exp.save

    return {msg: "Расходы за государство оплачены"}
  end

  def self.unpay_state_expenses
    st_exp = self.find_by(identificator: "current_year")
    st_exp.params["state_expenses"] = false #Делает отметку о том, что в текущем году расходы НЕ оплачены
    st_exp.save

    return {msg: "Расходы за государство оплачены"}
  end

  def self.set_default
    cy = GameParameter.find_by(identificator: "current_year")
    cy.params = false
    cy.value = "1"
    cy.save

    return {msg: "Параметры переведены в исходное состояние"}
  end

  def self.get_years_count
    setting = GameParameter.find_by(identificator: "years_count")
    if setting && setting.value
      setting.value.to_i
    else
      1 # Значение по умолчанию
    end
  end

  def self.update_years_count(value)
    setting = GameParameter.find_or_initialize_by(identificator: "years_count")
    setting.value = value.to_s
    setting.save

    return {msg: "Установлено #{value} лет в игре", years_count: value}
  end

  def self.get_caravan_robbery_settings
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    if setting && setting.params
      {
        robbery_by_year: setting.params['robbery_by_year'] || {},
        protected_guilds_by_year: setting.params['protected_guilds_by_year'] || {}
      }
    else
      {
        robbery_by_year: {},
        protected_guilds_by_year: {}
      }
    end
  end

  def self.update_caravan_robbery_settings(settings_hash)
    setting = GameParameter.find_or_initialize_by(identificator: "caravan_robbery_settings")
    setting.params ||= {}
    setting.params['robbery_by_year'] = settings_hash[:robbery_by_year] || {}
    setting.params['protected_guilds_by_year'] = settings_hash[:protected_guilds_by_year] || {}
    setting.save

    return {msg: "Настройки ограбления караванов обновлены", settings: setting.params}
  end

  def self.get_robbery_count_for_year(year)
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    if setting && setting.params && setting.params['robbery_by_year']
      setting.params['robbery_by_year'][year.to_s]&.to_i || 0
    else
      0
    end
  end

  def self.get_protected_guilds_for_year(year)
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    if setting && setting.params && setting.params['protected_guilds_by_year']
      setting.params['protected_guilds_by_year'][year.to_s] || []
    else
      []
    end
  end

  def self.add_protected_guild_for_year(guild_id, year)
    setting = GameParameter.find_or_initialize_by(identificator: "caravan_robbery_settings")
    setting.params ||= {}
    setting.params['protected_guilds_by_year'] ||= {}
    setting.params['protected_guilds_by_year'][year.to_s] ||= []
    
    # Добавляем ID гильдии, если его еще нет
    protected_list = setting.params['protected_guilds_by_year'][year.to_s]
    protected_list << guild_id.to_i unless protected_list.include?(guild_id.to_i)
    
    setting.params_will_change!
    setting.save
  end

  def self.get_caravans_per_guild
    setting = GameParameter.find_by(identificator: "caravans_per_guild")
    if setting && setting.value
      setting.value.to_i
    else
      1 # Значение по умолчанию
    end
  end

  def self.update_caravans_per_guild(value)
    setting = GameParameter.find_or_initialize_by(identificator: "caravans_per_guild")
    setting.value = value.to_s
    setting.save

    return {msg: "Установлено #{value} караванов в гильдии", caravans_per_guild: value}
  end

  # Статистика ограблений для скользящей вероятности
  def self.get_arrived_count_for_year(year)
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    if setting && setting.params && setting.params['arrived_count_by_year']
      setting.params['arrived_count_by_year'][year.to_s]&.to_i || 0
    else
      0
    end
  end

  def self.get_robbed_count_for_year(year)
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    if setting && setting.params && setting.params['robbed_count_by_year']
      setting.params['robbed_count_by_year'][year.to_s]&.to_i || 0
    else
      0
    end
  end

  def self.increment_arrived_count(year)
    setting = GameParameter.find_or_initialize_by(identificator: "caravan_robbery_settings")
    setting.params ||= {}
    setting.params['arrived_count_by_year'] ||= {}
    setting.params['arrived_count_by_year'][year.to_s] ||= 0
    setting.params['arrived_count_by_year'][year.to_s] += 1
    setting.save
  end

  def self.increment_robbed_count(year)
    setting = GameParameter.find_or_initialize_by(identificator: "caravan_robbery_settings")
    setting.params ||= {}
    setting.params['robbed_count_by_year'] ||= {}
    setting.params['robbed_count_by_year'][year.to_s] ||= 0
    setting.params['robbed_count_by_year'][year.to_s] += 1
    setting.save
  end

  def self.decrement_robbery_count_for_year(year)
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    setting.params['robbery_by_year'][year.to_s] -= 1
    setting.save
  end

  def self.reset_caravan_robbery_counters(year)
    setting = GameParameter.find_by(identificator: "caravan_robbery_settings")
    return unless setting
    
    setting.params ||= {}
    setting.params['arrived_count_by_year'] ||= {}
    setting.params['robbed_count_by_year'] ||= {}
    setting.params['arrived_count_by_year'][year.to_s] = 0
    setting.params['robbed_count_by_year'][year.to_s] = 0
    setting.save
  end

  def self.get_robbery_stats_for_current_year
    current_year = self.current_year
    {
      robbed_count: get_robbed_count_for_year(current_year),
      planned_robberies: get_robbery_count_for_year(current_year)
    }
  end
end
