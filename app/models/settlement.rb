class Settlement < ApplicationRecord
  belongs_to :settlement_type, optional: true
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  has_many :buildings
  validates :name, presence: { message: "Поле Название должно быть заполнено" }

  def income
    #Исправить
    return false
    self.settlement_type&.params["income"].to_i + self.buildings.sum{|b| b.income}
  end

  def build(building_type_id)
    already_there = self.buildings.any?{|b| b&.building_level&.building_type_id == building_type_id}
    building_level = BuildingLevel.find_by(level: BuildingLevel::FIRST_LEVEL, building_type_id: building_type_id)
    if already_there
      {building: nil, msg: "Во владении уже есть #{building_level&.name}."}
    else
      b = Building.create(settlement_id: self.id, building_level: building_level)
      {building: b, msg: "Во владении построено #{building_level&.name}."}
    end
  end
end
