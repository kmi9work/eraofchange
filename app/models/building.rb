class Building < ApplicationRecord
  belongs_to :building_level, optional: true
  belongs_to :settlement, optional: true
  BUIDING_MAX_LEVEL = 3


  def upgrade #возникла проблема с !.
    if self.building_level.level < BUIDING_MAX_LEVEL
      next_level = self.building_level.level + 1
      required_building_type = self.building_level.building_type
      self.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
      self.save
      return self.building_level
    end
    return nil
  end

  # def building_upgrade
  #   set = Settlement.find_by(id: self.id)
  #   if self.building_level.level < BUIDING_MAX_LEVEL
  #     building_to_upgrade = Building.find_by_id(self.id)
  #     next_level = self.building_level.level + 1
  #     required_building_type = self.building_level.building_type
  #     self.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
  #     self.save
  #   end
  # end

end

