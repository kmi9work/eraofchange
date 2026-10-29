class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок
  audited

  # Константы для княжеств Руси
  MOSCOW_KNYAZESTVO = 1
  VOLOGODSKOE_KNYAZESTVO = 2
  NIGERODSKOE_KNYAZESTVO = 3
  YAROSLAVSKOE_KNYAZESTVO = 4

  belongs_to :country
  belongs_to :player, optional: true

  has_many :settlements
  has_many :armies
  has_many :plant_places
  has_many :public_order_items

  # Регионы государства и всё остальное
  scope :for_country, ->(country) { country.nil? ? all : where(country_id: country.id) }
  scope :foreign_to, ->(country) { country.nil? ? all : where.not(country_id: country.id) }

  has_one :capital, -> { where(settlement_type_id: [SettlementType::CAPITAL, SettlementType::TYPE_REGION, SettlementType::CAP_REGION]) }, class_name: 'Settlement'

  def inf_buildings_on_po #Влияние зданий на общественный порядок
    bbl_params = self.settlements.joins(buildings: :building_level).
         where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
         pluck('buildings.params, building_levels.params')
    bbl_params.sum do |building_params, level_params| 
      level_params["public_order"].to_i
    end
  end

  def count_items
    public_order_items.sum(&:value)
  end

  def show_overall_po(country = Country.current)
    self.inf_buildings_on_po + self.count_items + (Technology.find(Technology::GODS_ANOITED).is_open(country) == 1 ? 5 : 0)
  end

  # Передать регион государству-получателю (how: 1 — войной, 0 — миром).
  #
  # Событие общественного порядка — для игроков государства-получателя: если за
  # страну никто не играет, отыгрывать изменение порядка некому, запись не
  # создаётся. Владения прежних владельцев сохраняются при передаче текущему
  # государству; регион, ушедший чужому государству, оставляет свои поселения
  # без владельцев.
  #
  # Влияние за ЗЕМЛЮ (не за государство) начисляется только по решению мастера —
  # его передаёт клиент флагами в `bonuses`:
  #   posol: true                 — Посольскому дьяку получателя +7
  #   grand_prince: true          — Великому князю получателя +5
  #   remove_posol: true          — снять 7 у Посольского дьяка прежнего государства
  #   remove_grand_prince: true   — снять 5 у Великого князя прежнего государства
  # Без флагов (клиент era_native) влияние не начисляется и не снимается.
  def captured_by(who_id, how, bonuses = {})
    receiver = Country.find_by(id: who_id.to_i)
    return {result: false, msg: "Государство не найдено"} if receiver.nil?

    bonuses = (bonuses || {}).to_h.symbolize_keys
    previous = country
    transferred = self.country_id != receiver.id

    if transferred
      self.country_id = receiver.id
      if receiver.players.exists?
        if how.to_i == Country::BY_WAR
          self.public_order_items << PublicOrderItem.add(Country::MILITARILY, "Регион присоединен войной", self)
        else
          self.public_order_items << PublicOrderItem.add(Country::PEACEFULLY, "Регион присоединен миром", self)
        end
      end
      self.settlements.update_all(player_id: nil) if receiver.id != Country.current&.id
      self.save
    end

    awarded = transferred ? award_land_influence(receiver, previous, bonuses) : []

    {
      result: true,
      msg: "Регион присоединен",
      transferred: transferred,
      previous_country_id: previous&.id,
      country_id: receiver.id,
      awarded: awarded
    }
  end

  def add_po_item(value, comment, entity) #Изменить общественный порядок
    PublicOrderItem.add(value, comment, self, entity)
  end

  private

  # Влияние должностей за присоединённую/утраченную землю.
  #
  # Начисляется за КАЖДУЮ землю: Посольский дьяк +Job::POSOL_BONUS (7), Великий
  # князь +Job::GRAND_PRINCE_BONUS (5). Снятие — теми же величинами со знаком
  # минус у совета прежнего государства: земля ушла другим игрокам, значит у них
  # бонус снимается, а у получателей добавляется.
  def award_land_influence(receiver, previous, bonuses)
    awarded = []

    if bonuses[:posol]
      awarded += land_influence_rows(receiver, Job::POSOL, Job::POSOL_BONUS,
                                     "Бонус за присоединение земли #{name}")
    end
    if bonuses[:grand_prince]
      awarded += land_influence_rows(receiver, Job::GRAND_PRINCE, Job::GRAND_PRINCE_BONUS,
                                     "Бонус за присоединение земли #{name}")
    end

    if previous && previous.id != receiver.id
      if bonuses[:remove_posol]
        awarded += land_influence_rows(previous, Job::POSOL, -Job::POSOL_BONUS,
                                       "Снятие бонуса за утрату земли #{name}")
      end
      if bonuses[:remove_grand_prince]
        awarded += land_influence_rows(previous, Job::GRAND_PRINCE, -Job::GRAND_PRINCE_BONUS,
                                       "Снятие бонуса за утрату земли #{name}")
      end
    end

    awarded
  end

  # Начисляет влияние всем игрокам должности в государстве и возвращает строки
  # для ответа клиенту: мастер должен видеть, кому и сколько ушло.
  def land_influence_rows(country, job_id, value, comment)
    country.council_players(job_id).map do |player|
      player.modify_influence(value, comment, self)
      {
        id: player.id,
        name: player.name,
        job_id: job_id,
        country_id: country.id,
        country_name: country.short_name.presence || country.name,
        value: value,
        comment: comment
      }
    end
  end
end
