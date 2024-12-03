class Player < ApplicationRecord
  # params:
  # influence (integer) - Влияние
  # contraband ([]) - Контрабанда

  belongs_to :human, optional: true
  belongs_to :player_type, optional: true
  belongs_to :family, optional: true
  belongs_to :job, optional: true
  belongs_to :guild, optional: true

  has_many :plants, :as => :economic_subject,
           :inverse_of => :economic_subject
  has_many :settlements
  has_many :armies
  has_many :credits
  has_many :political_actions

  validates :name, presence: { message: "Поле Имя должно быть заполнено" }

  def check_credit(plant_ids)
    plants = Plant.where(id: plant_ids)
    plants.all?{|p| p.credit_id.blank?}
  end

  def give_credit(plant_ids)
    if check_credit(plant_ids)
      plants = Plant.where(id: plant_ids)
      credit_deposit = 0
      credit_term = GameParameter.find_by(identificator: "credit_term")&.value.to_i
      credit_size = GameParameter.find_by(identificator: "credit_size")&.value.to_f / 100
      start_year = GameParameter.find_by(identificator: "current_year")&.value.to_i
      plants.each { |p| credit_deposit += p.plant_level.deposit }
      credit_sum = credit_deposit + ((credit_deposit * credit_size) * credit_term).round if credit_deposit.present?
      credit_new = self.credits.create(sum: credit_sum, deposit: credit_deposit, procent: credit_size, duration: credit_term, start_year: start_year)
      new_credit_id = credit_new.id
      plants_with_credit = plants.update(credit_id: new_credit_id)
      final_hash = {
        credit_deposit: credit_deposit, 
        credit_term: credit_term,
        credit_sum: credit_sum
      }
      return {result: final_hash, msg: "Кредит выдан"}
    else
      return {result: false, msg: "Кредит не выдан, одно или несколько предприятий уже находятся в залоге"}
    end
  end

  def add_army(army_size_id, region_id)
    self.armies.create(army_size_id: army_size_id, region_id: region_id)
  end

  def income
    self.settlements.sum{|s| s.income}
  end

  def player_military_outlays
    cost = {}
    self.armies.each do |army|
      maintenance_cost = army.army_size&.params&.dig('maintenance_cost')
      next unless maintenance_cost
      maintenance_cost.each do |res_id, value|
        cost[res_id] ||= 0
        cost[res_id] += value
      end
    end
    cost
  end

  def run_political_action(political_action_type_id, year, success, options)
    pat = PoliticalActionType.find_by_id(political_action_type_id)
    result = pat.execute(success, options)
    self.political_actions.create(year: year, success: success, params: result, political_action_type_id: political_action_type_id)
  end

  def modify_influence(num = nil) #Изменить влияние игрока
    num = 1 if num == nil
    self.params["influence"] += num
    self.save
  end
end
