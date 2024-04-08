class Settlement < ApplicationRecord
  belongs_to :settlement_type, optional: true
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  has_many :plant_places
  has_many :buildings
  validates :name, presence: { message: "Поле Название должно быть заполнено" }


  def build_church
    which_settlement = self.id
    which_building = BuildingLevel.find_by(name: "Часовня")
    Building.create(settlement_id: which_settlement, building_level: which_building)
  end

  def build_market
    which_settlement = self.id
    which_building = BuildingLevel.find_by(name: "Базар" )
    Building.create(settlement_id: which_settlement, building_level: which_building)
  end

  def build_fort
    if self.settlement_type.name == "Город"
      which_settlement = self.id
      which_building = BuildingLevel.find_by(name: "Форт" )
      Building.create(settlement_id: which_settlement, building_level: which_building)
    else
      puts "В деревне нельзя строить оборонительные сооружения"
    end
  end

  def build_garrison
    if self.settlement_type.name == "Город"
      which_settlement = self.id
      which_building = BuildingLevel.find_by(name: "Караул" )
      Building.create(settlement_id: which_settlement, building_level: which_building)
    else
      puts "В деревне нельзя размещать гарнизон"
    end
  end

  def name_of_building
    @bu = Building.building_level.building_type.find_by(title: "Религиозная постройка")
  end




end
