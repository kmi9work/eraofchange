class Player < ApplicationRecord
  # params:
  # infuence (integer) - Влияние

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

  def give_credit(economic_subject_id)
    plant = Plant.find_by_id(economic_subject_id)
      if plant.credit_id.blank?
        credit_new = self.credits.create
        new_credit_id = credit_new.id
        plant_with_credit = plant.update(credit_id: new_credit_id)
        {msg: "Сумма кредита:"}
      else
        {msg: "Нельзя выдать кредит, уже выдан"}
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
    if success
      pat = PoliticalActionType.find_by_id(political_action_type_id)
      result = pat.execute_success(options)
      self.political_actions.create(year: year, success: success, params: result)
    else
      result = pat.execute_fail(options)
      self.political_actions.create(year: year, success: success)
    end
  end
end
