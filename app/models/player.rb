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

  def check_credit(plant_ids)
    #1. Принадлежат ли эти предприятия игроку?
    #2. Свободны ли предприятия от кредита?
    belongs_to_player && empty_for_credit
  end

  def give_credit(plant_ids)
    if check_credit(plant_ids)
      # Для каждого предприятия создать кредит
      # credit_new = self.credits.create
      # new_credit_id = credit_new.id
      # plant_with_credit = plant.update(credit_id: new_credit_id)
      # Выводим сумму кредита равную сумме стоимостей всех предприятий. Срок кредита и финальную стоимость кредита
      return {result: true, msg: ""}
    else
      return {result: false, msg: "Нельзя выдать кредит, уже выдан"}
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
      renewal_cost = army.army_size&.params&.dig('renewal_cost')
      next unless renewal_cost
      renewal_cost.each do |res_id, value|
        cost[res_id] ||= 0
        cost[res_id] += value
      end
    end
    cost
  end

  def run_political_action(political_action_type_id, year, success, options)
    pat = PoliticalActionType.find_by_id(political_action_type_id)
    result = pat.execute(success, options)
    self.political_actions.create(year: year, success: success, params: result)
  end
end
