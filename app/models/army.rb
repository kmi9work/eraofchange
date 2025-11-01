class Army < ApplicationRecord
  # params:
  # palsy ([]) - Паралич
  audited
  
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  
  has_many   :troops, dependent: :destroy
  has_many   :attacker_battles, class_name: 'Battle', foreign_key: 'attacker_army_id'
  has_many   :defender_battles, class_name: 'Battle', foreign_key: 'defender_army_id'
  has_many   :winner_battles, class_name: 'Battle', foreign_key: 'winner_army_id'
  belongs_to :settlement, optional: true
  belongs_to :owner, polymorphic: true, optional: true
  
  validates :name, presence: true, uniqueness: { scope: :deleted_at, conditions: -> { where(deleted_at: nil) } }

  NUMBER_OF_SLOTS = 3

  def has_empty_slots?
    number_of_slots = NUMBER_OF_SLOTS
    hired_troops = self.troops.count
    hired_troops < number_of_slots
  end

  def add_troop(troop_type_id)
    if has_empty_slots?
      troop = self.troops.create(troop_type_id: troop_type_id, params: {'paid' => []})
      {troop: troop, msg: "Отряд успешно добавлен в армию"}
    else
      {troop: nil, msg: "В армии превышено число отрядов"}
    end
  end

  def lease_to(country)
    self.params["additional"] = {"leased_to" => country.id, "active" => true}
    self.save
  end

  def unlease
    self.params["additional"] ||= {}
    self.params["additional"]["active"] = false
    self.save if changed?
    
    # Поиск армии с активной арендой
    leased_army = Army.all.find do |army|
      army.params.dig("additional", "active") == true
    end
  
  # Если активных аренд нет, очищаем параметры игры
  unless leased_army
    g_p = GameParameter.find_by(identificator: GameParameter::LINGERING_EFFECTS)
    g_p&.params&.delete_if { |p| p["name_of_action"] == "transfere_army" }
    g_p&.save
  end
end


  def goto settlement_id
    return "НЕЛЬЗЯ" if self.owner.jobs.map(&:name).include?("Великий князь") && GameParameter.any_lingering_effects?("make_a_trip")

    settlement = Settlement.find_by_id(settlement_id)
    if settlement
      self.settlement_id = settlement.id
      self.save
    end
  end

  def power
    set = self.settlement
    add_p = set&.buildings&.first&.building_level&.building_type&.name == "Кремль" ? 1 : 0

    troops.sum{|t| t.power + add_p}

  end
  
  def soft_delete!
    update!(deleted_at: Time.current.to_s)
  end
  
  def deleted?
    deleted_at.present?
  end

  def attack enemy_id, voevoda_bonus
    enemy = Army.active.find_by_id(enemy_id)
    if enemy
      winner, looser = self.power > enemy.power ? [self, enemy] : [enemy, self]
      damage = (looser.power / 2.0).ceil
      
      # Создаем запись о сражении
      battle = Battle.create!(
        attacker_army: self,
        defender_army: enemy,
        winner_army: winner,
        attacker_owner_name: self.owner&.name,
        defender_owner_name: enemy.owner&.name,
        winner_owner_name: winner.owner&.name,
        attacker_army_name: self.name,
        defender_army_name: enemy.name,
        winner_army_name: winner.name,
        damage: damage,
        year: GameParameter.current_year,
        comment: "Сражение между армиями"
      )
      
      winner.troops.shuffle.each do |troop|
        h = troop.health
        troop.injure(damage)
        damage -= h
        break if damage <= 0
      end
      looser.soft_delete!
      if winner.owner.try(:job_ids)&.include?(Job::VOEVODA) or winner.owner.try(:job_ids)&.include?(Job::GRAND_PRINCE)
        Job.find_by_id(Job::VOEVODA).players.each do |player|
          player.modify_influence(Job::VOEVODA_BONUS, "Бонус за победу", winner) 
        end
      end
      winner
    else
      false
    end
  end
end
