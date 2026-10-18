class Army < ApplicationRecord
  # params:
  # palsy ([]) - Паралич
  audited
  
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  # Армии государства: армии, принадлежащие самому государству, и армии его знати.
  # Новой колонки country_id нет — принадлежность выводится из владельца.
  scope :for_country, ->(country) do
    next none if country.nil?

    noble_ids = Player.where(country_id: country.id, player_type_id: PlayerType::NOBLE).select(:id)
    where(owner_type: 'Country', owner_id: country.id).or(where(owner_type: 'Player', owner_id: noble_ids))
  end

  # Армии всех прочих государств (в том числе без владельца)
  scope :foreign_to, ->(country) do
    next all if country.nil?

    where.not(id: for_country(country).select(:id))
  end
  
  has_many   :troops, dependent: :destroy
  has_many   :attacker_battles, class_name: 'Battle', foreign_key: 'attacker_army_id'
  has_many   :defender_battles, class_name: 'Battle', foreign_key: 'defender_army_id'
  has_many   :winner_battles, class_name: 'Battle', foreign_key: 'winner_army_id'
  belongs_to :settlement, optional: true
  belongs_to :owner, polymorphic: true, optional: true
  
  validates :name, presence: true, uniqueness: { scope: :deleted_at, conditions: -> { where(deleted_at: nil) } }
  validate :owner_is_country_or_noble

  NUMBER_OF_SLOTS = 3

  # Государство армии выводится из владельца: страна — сама эта страна,
  # игрок — государство игрока (в БД владеть армией может только знать).
  def country
    case owner_type
    when 'Country' then owner
    when 'Player' then owner&.country
    end
  end

  def country_id
    country&.id
  end

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
    # Получаем текущие params или создаем пустой хеш
    current_params = self.params || {}
    
    # Создаем новый хеш с данными об аренде
    current_params["additional"] = {"leased_to" => country.name, "active" => true}
    
    # Присваиваем новый хеш
    self.params = current_params
    
    # КРИТИЧНО: Для JSON-полей нужно явно пометить как измененное
    self.params_will_change!
    
    self.save
  end

  def unlease
    # Получаем текущие params
    current_params = self.params || {}
    current_params["additional"] ||= {}
    current_params["additional"]["active"] = false
    
    # Присваиваем новый хеш
    self.params = current_params
    
    # КРИТИЧНО: Для JSON-полей нужно явно пометить как измененное
    self.params_will_change!
    
    self.save
    
    # Поиск армии с активной арендой
    leased_army = Army.all.find do |army|
      army.params.dig("additional", "active") == true
    end
  
    # Если активных аренд нет, очищаем параметры игры
    unless leased_army
      g_p = GameParameter.find_by(identificator: GameParameter::LINGERING_EFFECTS)
      if g_p && g_p.params.present?
        current_g_p_params = g_p.params || []
        new_params = current_g_p_params.reject { |p| p&.dig("name_of_action") == "transfere_army" }
        g_p.params = new_params
        g_p.params_will_change!
        g_p.save
      end
    end
  end

  def goto settlement_id
    settlement = Settlement.find_by_id(settlement_id)
    if settlement
      self.settlement_id = settlement.id
      self.save
    end
  end

  def defense_power
    building_bonus = self.settlement
      &.buildings
      &.joins(building_level: :building_type)
      &.where(building_types: { name: "Кремль" })
      &.pick("building_levels.level")
      .to_i

    power + building_bonus * self.troops.count
  end

  def attack_power
    power
  end

  def power
    troops.sum{|t| t.power}
  end
  
  def soft_delete!
    update!(deleted_at: Time.current.to_s)
  end
  
  def deleted?
    deleted_at.present?
  end

  def attack enemy_id, voevoda_bonus
    # Проверяем эффект SINGLE_ARMY_COMPLETE_BLOCK для воеводы
    # Проверяем только если owner - Player (не Country)
    if self.owner_type == 'Player' && 
       self.owner.respond_to?(:jobs) &&
       self.owner.jobs.map(&:name).include?("Воевода") && 
       GameParameter.any_lingering_effects?("single_army_complete_block", GameParameter.current_year, self.owner.name)
      return "НЕЛЬЗЯ - Воевода не может командовать армией (эффект 'Защита каравана')"
    end
    
    enemy = Army.active.find_by_id(enemy_id)
    if enemy
      winner, looser = self.attack_power > enemy.defense_power ? [self, enemy] : [enemy, self]
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
        bonus_country = winner.country || Country.current
        bonus_country&.council_players(Job::VOEVODA)&.each do |player|
          player.modify_influence(Job::VOEVODA_BONUS, "Бонус за победу", winner) 
        end
      end
      winner
    else
      false
    end
  end

  private

  # Владеть армией может государство или игрок-знать (до перехода ограничение
  # держал только интерфейс, в БД его не было)
  def owner_is_country_or_noble
    return if owner_type.blank? && owner_id.blank?

    unless %w[Player Country].include?(owner_type.to_s)
      errors.add(:owner_type, "должен быть Player или Country")
      return
    end

    return unless owner_type.to_s == 'Player'

    if owner.nil?
      errors.add(:owner, "не найден")
    elsif owner.player_type_id != PlayerType::NOBLE
      errors.add(:owner, "владельцем армии игрока может быть только знать")
    end
  end
end
