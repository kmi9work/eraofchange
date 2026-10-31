class Settlement < ApplicationRecord
  # params:
  # open_gate (bool) - открыты ворота (штурм можно вести без осадных оружий)
  audited

  belongs_to :settlement_type, optional: true
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  has_many :buildings
  has_many :armies
  validates :name, presence: { message: "Поле Название должно быть заполнено" }

  # Поселения государства (страна поселения — страна его региона)
  scope :for_country, ->(country) do
    country.nil? ? all : joins(:region).where(regions: { country_id: country.id })
  end
  scope :foreign_to, ->(country) do
    country.nil? ? all : joins(:region).where.not(regions: { country_id: country.id })
  end

  # Страна поселения — страна региона
  def country
    region&.country
  end

  def country_id
    region&.country_id
  end

  def income
    self.settlement_type&.params["income"].to_i + self.buildings.sum{|b| b.income}
  end

  def sorted_buildings
    buildings.joins(:building_level).order('building_levels.building_type_id')
  end

  def build(building_type_id)
    return if building_type_id.blank?
    # Перечитываем постройки с сервера: `Building.create` ниже не обновляет кэш
    # ассоциации, и повторный вызов этим же объектом видел пустой список —
    # создавал дубль постройки и дубль уведомления мастеру сражений.
    self.buildings.reload
    already_there = self.buildings.any?{|b| b&.building_level&.building_type_id == building_type_id}
    building_level = BuildingLevel.find_by(level: BuildingLevel::FIRST_LEVEL, building_type_id: building_type_id)
    if already_there
      {building: nil, msg: "Во владении уже есть #{building_level&.name}."}
    else
      b = Building.create(settlement_id: self.id, building_level: building_level)
      # Крепость строят за столом Мастера сражений: и веб-админка (Ownership.vue),
      # и политдействие вассалов «Возвести форт» идут через этот метод, поэтому
      # уведомление живёт здесь, а не в контроллере.
      if building_level&.building_type_id == BuildingType::DEFENCE
        NotificationRule.fortress_changed(b, :built)
      end
      {building: b, msg: "Во владении построено #{building_level&.name}."}
    end
  end

  def pay_for_church
    rel_building = self.buildings.joins(:building_level).
                find_by(building_levels: {building_type_id: BuildingType::RELIGIOUS})
    if rel_building.params["paid"].include?(GameParameter.current_year)
      {result: false, msg: "За эту церковь уже внесены расходы"}
    else
      rel_building.params["paid"].push(GameParameter.current_year)
      rel_building.save
      {result: true, msg: "Расходы за церковь внесены"}
    end
  end
end

