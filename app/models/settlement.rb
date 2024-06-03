class Settlement < ApplicationRecord
  belongs_to :settlement_type, optional: true
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  has_many :plant_places
  has_many :buildings
  validates :name, presence: { message: "Поле Название должно быть заполнено" }

  def income
    self.settlement_type&.params["income"].to_i + self.buildings.sum{|b| b.income}
  end

  def build(type_of_building)
    already_there = self.buildings.any?{|b| b&.building_level&.building_type_id == type_of_building}
    which_building = BuildingLevel.find_by(level: BuildingLevel::FIRST_LEVEL, building_type_id: type_of_building)
    if already_there
      {building: nil, msg: "Во владении уже есть #{which_building&.name}."}
    else
      b = Building.create(settlement_id: self.id, building_level: which_building)
      {building: b, msg: "Во владении построено #{which_building&.name}."}
    end
  end

end
