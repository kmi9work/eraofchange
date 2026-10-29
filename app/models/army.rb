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

  NUMBER_OF_SLOTS = 3   # обычные отряды (пехота, тяжёлая пехота, кавалерия)
  CANNON_SLOTS = 1      # пушка — сверх трёх отрядов, не больше одной

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

  # Отряды без пушки: именно они ограничены тремя слотами.
  def regular_troops
    troops.where.not(troop_type_id: TroopType::CANNON)
  end

  def cannons
    troops.where(troop_type_id: TroopType::CANNON)
  end

  # Есть ли место под отряд этого типа. Без аргумента — есть ли место хоть под
  # какой-нибудь отряд (пушка занимает свой отдельный слот).
  def has_empty_slots?(troop_type_id = nil)
    return regular_troops.count < NUMBER_OF_SLOTS if troop_type_id.nil?
    return cannons.count < CANNON_SLOTS if troop_type_id.to_i == TroopType::CANNON

    regular_troops.count < NUMBER_OF_SLOTS
  end

  def add_troop(troop_type_id)
    unless has_empty_slots?(troop_type_id)
      msg = if troop_type_id.to_i == TroopType::CANNON
              "В армии уже есть пушка: больше одной пушки в армию не ставится"
            else
              "В армии уже #{NUMBER_OF_SLOTS} отряда: сначала освободите место"
            end
      return { troop: nil, msg: msg }
    end

    troop = self.troops.create(troop_type_id: troop_type_id, params: {'paid' => []})
    unless troop.persisted?
      return { troop: nil, msg: "Отряд не создан: #{troop.errors.full_messages.join(', ')}" }
    end

    { troop: troop, msg: "Отряд успешно добавлен в армию" }
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
      self.class.award_victory_influence([winner], [looser])
      winner
    else
      false
    end
  end

  # Влияние Воеводе за сражение (решение заказчика).
  #
  # Бонус даётся за КАЖДУЮ разбитую армию противника: `Job::VOEVODA_BONUS` (+4) —
  # совету Воеводы государства-победителя. Гарнизон города армией на сервере не
  # является и бонуса не даёт. Должность командующего роли не играет: победа любой
  # армии государства приносит бонус его Воеводе.
  #
  # За каждую разбитую армию игрока проигравшее государство получает
  # `Job::VOEVODA_PENALTY` (−1) совету Воеводы — симметрично бонусу.
  #
  # Вызывается из `Army#attack` (веб-админка, бой 1×1) и
  # `ArmiesController#award_battle_victory` (era_native, где бой считается на
  # клиенте). Возвращает список награждённых и оштрафованных — клиенту он нужен,
  # чтобы показать мастерам результат.
  def self.award_victory_influence(armies, defeated_armies = [])
    winners = Array(armies).compact
    defeated = Array(defeated_armies).compact
    return [] if winners.empty? || defeated.empty?

    awarded = []
    winner_countries = winners.map(&:country).compact.uniq
    losers = defeated.group_by(&:country).reject { |country, _| country.nil? }

    # +4 за каждую разбитую армию противника
    winner_countries.each do |country|
      count = losers.sum { |loser_country, list| loser_country.id == country.id ? 0 : list.size }
      next if count.zero?

      country.council_players(Job::VOEVODA).each do |player|
        value = Job::VOEVODA_BONUS * count
        player.modify_influence(value, "Бонус за победу (разбито армий: #{count})", winners.first)
        awarded << award_row(player, country, value, 'bonus')
      end
    end

    # −1 за каждую разбитую армию своего государства
    losers.each do |country, list|
      next if winner_countries.any? { |winner| winner.id == country.id }

      country.council_players(Job::VOEVODA).each do |player|
        value = Job::VOEVODA_PENALTY * list.size
        player.modify_influence(value, "Поражение в сражении (потеряно армий: #{list.size})", list.first)
        awarded << award_row(player, country, value, 'penalty')
      end
    end

    awarded
  end

  def self.award_row(player, country, value, role)
    {
      id: player.id,
      name: player.name,
      country_id: country.id,
      country_name: country.name,
      value: value,
      role: role
    }
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
