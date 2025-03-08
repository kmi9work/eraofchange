class GameParameter < ApplicationRecord
  audited

  NO_STATE_EXPENSES = -5

  def self.increase_year #Переводит в следующий год
    # автоматически убирает или понижает в уровне
    # все не оплаченные на момент смены года армии
    #Army.all.each {|a| a.check_and_demote_army!} #метод работает

    current_year = GameParameter.find_by(identificator: "current_year")
    if current_year.params["state_expenses"] == false
      PublicOrderItem.add(NO_STATE_EXPENSES, "Не оплачены расходы", nil, nil)
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
