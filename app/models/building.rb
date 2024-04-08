class Building < ApplicationRecord
  belongs_to :building_level, optional: true
  belongs_to :settlement, optional: true


  def upgrade
    @building_to_upgrade = Building.find_by(params[:id])
    if @building_to_upgrade.building_level.level < 3
      next_level = @building_to_upgrade.building_level.level + 1
      required_building_type = @building_to_upgrade.building_level.building_type
      @building_to_upgrade.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
      @building_to_upgrade.save
    end
  end



end

