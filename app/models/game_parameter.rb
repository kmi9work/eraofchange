class GameParameter < ApplicationRecord

  TIMER = 4
  NO_STATE_EXPENSES = -5
  NOT_TICKING = 0


  SCHEDULE = [
              {identificator: "Регистрация игроков", start: "10:30", finish: "11:00"},
              {identificator: "Инструктаж", start: "11:00",  finish: "11:30"},
              {identificator: "Первый цикл", start: "11:30",  finish: "13:00"},
              {identificator: "Второй цикл", start: "13:00",  finish: "14:00"},
              {identificator: "Обед", start:"14:00",    finish: "14:30"},
              {identificator: "Третий цикл", start: "14:30",  finish: "15:30"},              
              {identificator: "Четвертый цикл", start: "15:30",  finish: "16:30"},
              {identificator: "Пятый цикл", start: "16:30",  finish: "17:30"}
            ]

  def self.create_temp_schedule
    dummy_schedule = []
    minutes_to_add = 2

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


  def self.toggle_timer
    timer = GameParameter.find(TIMER)
    timer.value = 1-timer.value.to_i
    timer.save
  end

  def self.modify_date(time_stringified)
    date = Time.zone.today.strftime
    date += " #{time_stringified}"
    time =  Time.strptime(date, "%Y-%m-%d %H:%M")
    unix_time = time.to_i
    return unix_time
  end

  def self.show_schedule
    timer = GameParameter.find(TIMER)
    schedule_item = {}
    schedule = timer.params.map do |item|
        {
          identificator: item["identificator"].to_s,
          unix_start: GameParameter.modify_date(item["start"]),
          unix_finish: GameParameter.modify_date(item["finish"])
        }
    end
    return {schedule: schedule, ticking: timer.value}
  end

  def self.create_schedule(schedule = nil)
    timer = GameParameter.find(TIMER)
    timer.value = NOT_TICKING 
    timer.params = []
    timer.params = schedule || SCHEDULE
    timer.save
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
