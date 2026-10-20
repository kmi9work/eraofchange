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
  def captured_by(who_id, how)
    receiver = Country.find_by(id: who_id.to_i)
    return {result: false, msg: "Государство не найдено"} if receiver.nil?

    if self.country_id != receiver.id
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

    {result: true, msg: "Регион присоединен"}
  end

  def add_po_item(value, comment, entity) #Изменить общественный порядок
    PublicOrderItem.add(value, comment, self, entity)
  end
end
