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
    plants = Plant.where(id: plant_ids)
    #Нужно переписать для нескольких предприятий. Если хотя бы одно предприятие в кредите - выдать ошибку
    plants.economic_subject_id == self.id && plants.credit.blank?
    #true: "Предприятие принадлежит игроку и нет кредита"}
  end

  def give_credit(plant_ids)
    if check_credit(plant_ids)
      plants = Plant.where(id: plant_ids)
      #Нужно переписать для нескольких предприятий. Нужно создать один Credit. И к нему прикрепить несколько plants.
      credit_new = self.credits.create(sum: plants.plant_level&.deposit)
      new_credit_id = credit_new.id
      plant_with_credit = plants.update(credit_id: new_credit_id)

      credit_sum = plants.plant_level&.deposit
      credit_term = GameParameter.find_by(identificator: "credit_term").value.to_i
      credit_size = GameParameter.find_by(identificator: "credit_size").value.to_f / 100
      final_value = credit_sum + ((credit_sum * credit_size) * credit_term) if credit_sum.present?
      final_hash = {
        credit_sum: credit_sum, 
        credit_term: credit_term,
        final_value: final_value
      }
      return {result: final_hash, msg: "Кредит выдан"}
    else
      return {result: false, msg: "Нельзя выдать кредит"}
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
end

