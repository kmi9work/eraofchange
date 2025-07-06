class GameParameter < ApplicationRecord

  ADDITIONAL_TIME = 1800 #Дополнительное время для цикла, когда длительность больше, чем в обычном цикле
  SPECIAL_YEARS = [1]
  TIMER = 4
  NO_STATE_EXPENSES = -5

  def self.show_time   
    timer = GameParameter.find(TIMER)

    #Когда таймер еще ни разу не запускался   
    if GameParameter.new_start?
      return GameParameter.set_cycle_len
    
    #Таймер уже запускался, и его нужно обновить, потому что была перезагрузка фронта.
    else
      return  GameParameter.ticking? ? GameParameter.count_down  : timer.params.last["remaining"]
    end
  end

  def self.show 
    return Time.at(GameParameter.show_time).utc.strftime("%H:%M:%S")
  end

  def self.switch_timer #switch
    timer = GameParameter.find(TIMER)
    if GameParameter.new_start?
      timer.params.push({"year"=>"#{GameParameter.current_year}", 
                        "ticking" => "1",
                        "start"=>"#{Time.now.to_i}", 
                        "remaining"=>"#{GameParameter.set_cycle_len}", 
                        "finish"=>"#{Time.now.to_i + GameParameter.set_cycle_len}"})
    elsif !GameParameter.ticking?
      timer.params.last["ticking"] = "1"
      timer.params.last["finish"]  = Time.now.to_i + timer.params.last["remaining"]
    elsif GameParameter.ticking?
      timer.params.last["remaining"] = GameParameter.count_down
      timer.params.last["ticking"]   = "0"
    end  

    timer.save
  end

  #Проверяет, относится ли текущий год к числу тех годов, которые идут дольше. Сейчас это только первый год. 
  def self.set_cycle_len
    SPECIAL_YEARS.include?(GameParameter.current_year) ? c_l = GameParameter.find(TIMER).value.to_i + ADDITIONAL_TIME : c_l = GameParameter.find(TIMER).value.to_i 
    return  c_l
  end

  #Проверяет, не запущен ли таймер на данный момент. 
  def self.ticking?
    return false if GameParameter.find(TIMER).params.empty?
    return  GameParameter.find(TIMER).params.last["ticking"].to_i > 0
  end

  #Проверяет, не создан ли параметр таймера вообще или на текущий год. 
  def self.new_start?
    timer = GameParameter.find(TIMER)
    if timer.params.empty? or timer.params.last["year"].to_i != GameParameter.current_year 
      return true 
    else
      return false
    end
  end

  #Отслеживает, сколько секунд осталось до устанновленного конечного времени. 
  #Если конечное время достигнуто, возвращает 0.
  def self.count_down
    timer = GameParameter.find(TIMER)
    timer.params.last["finish"].to_i - Time.now.to_i > 0 ? t_r = timer.params.last["finish"].to_i - Time.now.to_i : t_r = 0
    return t_r
  end

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
