class BuildingLevel < ApplicationRecord
  belongs_to :building_type, optional: true
  has_many :buildings
end

