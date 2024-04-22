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

  def build_church
    already_there = self.buildings.any?{|b| b&.building_level&.building_type_id == BuildingType::RELIGIOUS}

    if already_there
      {building: nil, msg: "Во владении уже есть религиозная постройка."}
    else
      which_building = BuildingLevel.find_by(level: BuildingLevel::FIRST_LEVEL, building_type_id: BuildingType::RELIGIOUS)
      b = Building.create(settlement_id: self.id, building_level: which_building)
      {building: b, msg: "Во владении построено #{which_building&.name}."}
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
      if self.settlement_type ==  SettlementType.find_by_id(SettlementType::TOWN)
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
      if self.settlement_type ==  SettlementType.find_by_id(SettlementType::TOWN)
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
