class GameParameter < ApplicationRecord

  def self.change_year #Переводит в следующий год
    ny = GameParameter.find_by(identificator: "current_year")
    if self.show_current_year <=5 # на случай резервного года
      ny.params = GameParameter.find_by(identificator: "game_years").params[self.show_current_year]
      ny.save

      po = self.find_by(identificator: "state_expenses")
      po.value = false
      po.save

      {msg: "Наступил следующий год"}
    else
      {msg: "Превышено число годов"}
    end
  end

  def self.show_current_year #показывает номер года
    GameParameter.find_by(identificator: "current_year").params["year_number"].to_i
  end


  def self.pay_state_expenses
    po = self.find_by(identificator: "state_expenses")
    st_exp = self.find_by(identificator: "current_year")
    st_exp.params["state_expenses"] = true #Делает отметку о том, что в текущем году расходы оплачены
    st_exp.save
    po.value = true
    po.save
  end

  def self.set_default
    cy = GameParameter.find_by(identificator: "current_year")
    cy.params = GameParameter.find_by(identificator: "game_years").params[0]
    cy.save
  end


end
