class BuildingLevel < ApplicationRecord
  # params:
  # income (integer) - Доход
  belongs_to :building_type, optional: true
  has_many :buildings
end

