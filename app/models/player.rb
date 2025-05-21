class Player < ApplicationRecord
  # params:
  # influence (integer) - Влияние
  # contraband ([]) - Контрабанда
  audited

  belongs_to :human, optional: true
  belongs_to :player_type, optional: true
  belongs_to :family, optional: true
  has_and_belongs_to_many :jobs
  belongs_to :guild, optional: true

  has_many :plants, :as => :economic_subject,
           :inverse_of => :economic_subject
  has_many :settlements
  has_many :armies, :as => :owner,
           :inverse_of => :owner
  has_many :credits
  has_many :political_actions
  has_many :influence_items

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
    sum = 0
    if job_ids.include?(Job::METROPOLITAN)
      church_params = Building.joins({settlement: :region}, :building_level).
        where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
        where(regions: {country_id: Country::RUS}).
        select('building_levels.params')
      sum += church_params.map{|p| p.params['metropolitan_income'].to_i}.sum
    end
    sum + self.settlements.sum{|s| s.income + (Technology.find(Technology::ST_GEORGE_DAY).is_open == 1 ? 1000 : 0)}
  end

  def player_military_outlays
    cost = 0
    self.armies.each do |army|
      cost += army.troops.count * Troop::RENEWAL_COST
    end
    cost
  end

  def run_political_action(political_action_type_id, year, success, options)
    pat = PoliticalActionType.find_by_id(political_action_type_id)
    result = pat.execute(success, options)
    self.political_actions.create(year: year, success: success, params: result, political_action_type_id: political_action_type_id)
  end

  def self.all_contrabandists
    Player.all.select{|p| p.params["contraband"]&.include?(GameParameter.current_year)}
  end

  def modify_influence(value, comment, entity) #Изменить влияние игрока
    InfluenceItem.add(value, comment, self, entity)
  end

  def influence_buildings
    sum = 0
    if job_ids.include?(Job::METROPOLITAN)
      church_params = Building.joins({settlement: :region}, :building_level).
        where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
        where(regions: {country_id: Country::RUS}).
        select('building_levels.params')
      sum += church_params.map{|p| p.params['metropolitan_influence'].to_i}.sum
    end
    def_params = Building.joins({settlement: :region}, :building_level).
      where(building_levels: {building_type_id: BuildingType::DEFENCE}).
      where(regions: {country_id: Country::RUS}).
      where(settlements: {player_id: self.id}).
      select('building_levels.params')
    sum + def_params.map{|p| p.params['influence'].to_i}.sum
  end

  def influence
    influence_buildings + influence_items.sum{|ii| ii.value.to_i}
  end
end

