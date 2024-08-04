class GameParameter < ApplicationRecord
  GAME_YE_PARAMS = [{"year_number" => "1", "event" => "","state_expenses" => false},
                  {"year_number" => "2", "event" => "","state_expenses" => false},
                  {"year_number" => "3", "event" => "boom","state_expenses" => false},
                  {"year_number" => "4", "event" => "plague","state_expenses" => false},
                  {"year_number" => "5", "event" => "", "state_expenses" => false},
                  {"year_number" => "6", "event" => "","state_expenses" => false}]

  def self.increase_year #Переводит в следующий год
    ny = GameParameter.find_by(identificator: "current_year")
      ny.params = GameParameter.find_by(identificator: "game_years").params[self.current_year]
      ny.save
      if self.current_year > 5
        new_entry = GameParameter.find_by(identificator: "game_years")
        new_entry.params[self.current_year] = {"year_number" => "#{self.current_year + 1}",
            "event" => "", "state_expenses" => false}
        new_entry.save
      end
      return {msg: "Наступил следующий год"}
  end

  def self.current_year #показывает номер года
    GameParameter.find_by(identificator: "current_year").params["year_number"].to_i
  end

  def self.pay_state_expenses
    st_exp = self.find_by(identificator: "current_year")
    st_exp.params["state_expenses"] = true #Делает отметку о том, что в текущем году расходы оплачены
    st_exp.save

    return {msg: "Расходы за государство оплачены"}
  end

  def self.set_default
    cy = GameParameter.find_by(identificator: "current_year")
    cy.params = GameParameter.find_by(identificator: "game_years").params[0]
    cy.save
    gy = GameParameter.find_by(identificator: "game_years")
    gy.params = GAME_YE_PARAMS
    gy.save
    return {msg: "Параметры переведены в исходное состояние"}
  end


end
