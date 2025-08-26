class GameParameter < ApplicationRecord

  TIMER = 4
  SCREEN = 5
  DEFAULT_SCREEN = "placeholder"
  RESULTS = 6

  NO_STATE_EXPENSES = -5
  NOT_TICKING = 0

  SCHEDULE = [
            {id: 1, identificator: "Регистрация игроков", start: "10:30", finish: "11:00"},
            {id: 2, identificator: "Инструктаж", start: "11:00",  finish: "11:30"},
            {id: 3, identificator: "Первый цикл", start: "11:30",  finish: "13:00"},
            {id: 4, identificator: "Второй цикл", start: "13:00",  finish: "14:00"},
            {id: 5, identificator: "Обед", start:"14:00",    finish: "14:30"},
            {id: 6, identificator: "Третий цикл", start: "14:30",  finish: "15:30"},              
            {id: 7, identificator: "Четвертый цикл", start: "15:30",  finish: "16:30"},
            {id: 8, identificator: "Пятый цикл", start: "16:30",  finish: "17:30"}
          ]

  ###Результаты
def self.sort_and_save_results(result_hash = nil)

    game_results = GameParameter.find(RESULTS)
    game_results.params.transform_keys!(&:to_sym) ### ключи в символы
    if game_results.params.empty? || !game_results.params.has_key?(:merchant_results) || game_results.params[:merchant_results].empty?
      game_results.params[:merchant_results] = []
      max_id = 0
    else
      game_results.params[:merchant_results].map! {|res| res.transform_keys(&:to_sym)}
      max_id = game_results.params[:merchant_results].max_by { |h| h[:player_id]}[:player_id]
    end

    if result_hash != nil
      result_hash[:player_id] = max_id + 1  ##заменить на merchant_id
      results = game_results.params[:merchant_results].push(result_hash)
    else
      results = game_results.params[:merchant_results]
    end

    results.map! {|res| res.transform_keys(&:to_sym)}
    game_results.params[:merchant_results] = GameParameter.sort_and_rank_results(results)  
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

  def self.find_cap_per_pl(results)    
    per_pl_cap = []
    results.map! {|par| par.transform_keys(&:to_sym)}
    results.each do |result|
      num_of_players = result[:number_of_players].to_i > 0 ? result[:number_of_players].to_i : 1
      capital = result[:capital].to_i
      result[:cap_per_pl] = capital/num_of_players

      per_pl_cap << result
    end

    return per_pl_cap
  end

  def self.update_results(result_hash)   
    result_hash.transform_keys!(&:to_sym) 
    game_results = GameParameter.find(RESULTS)
    game_results.params.transform_keys!(&:to_sym) ### ключи хэша
    game_results.params[:merchant_results].map! {|par| par.transform_keys!(&:to_sym)}
    
    updated_params = game_results.params[:merchant_results].map do |result|
      if result_hash[:player_id] == result[:player_id]
        result_hash 
      else
        result 
      end
    end

    game_results.params[:merchant_results] = GameParameter.sort_and_rank_results(updated_params)
    game_results.save
  end

  def self.delete_result(player_id_hash)
    game_results = GameParameter.find(RESULTS)
    game_results.params.transform_keys!(&:to_sym)
    player_id_hash.transform_keys!(&:to_sym)
    game_results.params[:merchant_results].map! {|par| par.transform_keys(&:to_sym)}
    game_results.params[:merchant_results].delete_if{|h| h[:player_id] == player_id_hash[:player_id] }
    game_results.params[:merchant_results] = GameParameter.sort_and_rank_results(game_results.params[:merchant_results])

    game_results.save
  end

  def self.show_sorted_results
    game_results = GameParameter.find(RESULTS)
    game_results.params.transform_keys!(&:to_sym)
    return []  if game_results.params.empty? || !game_results.params.has_key?(:merchant_results) 

    game_results.params[:merchant_results].map! {|par| par.transform_keys(&:to_sym)}
    game_results.params[:merchant_results] = GameParameter.sort_and_rank_results(game_results.params[:merchant_results])
    game_results.save
    game_results.params.transform_keys!(&:to_sym)
    return game_results.params[:merchant_results]
  end  

  def self.clear_results
    game_results = GameParameter.find(RESULTS)
    game_results.params = []
    game_results.save
  end






###Управление экраном
  def self.toggle_screen(screen_value)
    screen = GameParameter.find(SCREEN)
    screen.value = screen_value
    screen.save 
  end

  def self.get_screen
    return GameParameter.find(SCREEN).value
  end

###Таймер и расписание

  def self.show_schedule
    timer = GameParameter.find(TIMER)
    schedule_item = {}
    id = 0
    schedule = timer.params.map do |item|
        id += 1
        { id: id,
          identificator: item["identificator"].to_s,
          start: item["start"],
          unix_start: GameParameter.modify_date(item["start"]),
          finish: item["finish"],
          unix_finish: GameParameter.modify_date(item["finish"])
        }
    end
    
    return {schedule: schedule, ticking: timer.value}
  end

  def self.add_schedule_item(schedule_item)
    #{"identificator"=>"Пятый цикл", "finish"=>"18:30"}
    timer = GameParameter.find(TIMER)
    params = timer.params
    new_start = params.last["finish"]
    last_id = params.last["id"]
    new_item   = {id: last_id + 1,
                  identificator: schedule_item["identificator"], 
                  start: new_start,
                  finish: schedule_item["finish"]
                }
    timer.params << new_item
    timer.save
  end

  def self.update_schedule_item(schedule_item)
    timer = GameParameter.find(TIMER)
    new_schedule = timer.params.map{|item| item["id"] == schedule_item["id"] ? schedule_item : item}
    timer.params = new_schedule
    timer.save
  end

  def self.delete_schedule_item(schedule_item_id)
    timer = GameParameter.find(TIMER)
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
      dummy_schedule_item[:identificator] = "Цикл #{item_name}"
      dummy_schedule_item[:start]  = current_time.strftime("%H:%M")
      current_time += (minutes_to_add * 60)
      dummy_schedule_item[:finish] = current_time.strftime("%H:%M")
      item_name += 1
      dummy_schedule.push(dummy_schedule_item)
    end

    GameParameter.create_schedule(dummy_schedule)
  end

  def self.toggle_timer(value = nil)    
    timer = GameParameter.find(TIMER)
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
    timer = GameParameter.find(TIMER)
    timer.value = NOT_TICKING 
    timer.params = []
    timer.params = schedule || SCHEDULE
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
end
