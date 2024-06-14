class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок

  belongs_to :country

  has_many :settlements
  has_many :armies

  def inf_buildings_on_po
    bl_params = self.settlements.joins(buildings: :building_level).
         where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
         pluck('building_levels.params')
    bl_params.sum{|p| p["public_order"].to_i}
  end
end
