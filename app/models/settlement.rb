class Settlement < ApplicationRecord
  belongs_to :settlement_type, optional: true
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  has_many :plant_places
  has_many :buildings
  validates :name, presence: { message: "Поле Название должно быть заполнено" }

  RELIGIOUS_BUILDING = 1 #"Религиозная постройка"
  DEFENCE_BUILDING = 2 #"Обронительная постройка"
  TRADE_BUILDING = 3 #"Торговая постройка"
  GUARDING_TROOP = 4  #"Размер постройка"

  FIRST_LEVEL = 1 #Первый уровень

  TOWN_SETTLEMENT_TYPE = 1 #"Тип поселения - город"
  VILLAGE_SETTLEMENT_TYPE = 2 #"Тип поселения - деревня"





  def build_church
    already_there = false
    self.buildings.each do |build|
      if build.building_level.building_type == BuildingType.find_by_id(RELIGIOUS_BUILDING)
        already_there = true
      end
    end
      unless already_there == true
        building_type = BuildingType.find_by_id(RELIGIOUS_BUILDING)
        which_building = BuildingLevel.find_by(level: FIRST_LEVEL, building_type: building_type)
        Building.create(settlement_id: self.id, building_level: which_building)
      else
        puts "Во владении уже есть религиозная постройка."
      end

  end

  def build_fort
    already_there = false
    self.buildings.each do |build|
      if build.building_level.building_type == BuildingType.find_by_id(DEFENCE_BUILDING)
        already_there = true
      end
    end
    unless already_there == true
      if self.settlement_type ==  SettlementType.find_by_id(TOWN_SETTLEMENT_TYPE)
        building_type = BuildingType.find_by_id(DEFENCE_BUILDING)
        which_building = BuildingLevel.find_by(level: FIRST_LEVEL, building_type: building_type)
        Building.create(settlement_id: self.id, building_level: which_building)
      else
        puts "В деревне нельзя строить оборонительные сооружения"
      end
    else
        puts "Во владении уже есть оборонительная постройка."
    end
  end

  def build_market
    already_there = false

    self.buildings.each do |build|
      if build.building_level.building_type == BuildingType.find_by_id(TRADE_BUILDING)
        already_there = true
      end
    end

    unless already_there == true
        building_type = BuildingType.find_by_id(TRADE_BUILDING)
        which_building = BuildingLevel.find_by(level: FIRST_LEVEL, building_type: building_type)
        Building.create(settlement_id: self.id, building_level: which_building)
    else
        puts "Во владении уже есть торговая постройка."
    end
  end

  def build_garrison
    already_there = false
    self.buildings.each do |build|
      if build.building_level.building_type == BuildingType.find_by_id(GUARDING_TROOP)
        already_there = true
      end
    end

    unless already_there == true
      if self.settlement_type ==  SettlementType.find_by_id(TOWN_SETTLEMENT_TYPE)
          building_type = BuildingType.find_by_id(GUARDING_TROOP)
          which_building = BuildingLevel.find_by(level: FIRST_LEVEL, building_type: building_type)
          Building.create(settlement_id: self.id, building_level: which_building)
      else
          puts "В деревне нельзя размещать гарнизон"
      end
    else
        puts "Во владении уже размещен гарнизон."
    end
  end


end
