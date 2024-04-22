class Building < ApplicationRecord
  belongs_to :building_level, optional: true
  belongs_to :settlement, optional: true
  BUIDING_MAX_LEVEL = 3

  def upgrade!
    level = self.building_level&.level
    if level < BUIDING_MAX_LEVEL
      next_level = level + 1
      required_building_type = self.building_level.building_type
      self.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
      self.save
      return {building_level: self.building_level, msg: "Новый уровень постройки: #{self.building_level&.name}"}
    end
    return {building_level: nil, msg: "Уровень максимальный. Улучшить невозможно."}
  end

  def income
    self.building_level&.params&.dig("income").to_i
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

