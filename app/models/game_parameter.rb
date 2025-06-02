class GameParameter < ApplicationRecord
  audited

  NO_STATE_EXPENSES = -5

  def self.increase_year(kaznachei_bonus) #Переводит в следующий год
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
