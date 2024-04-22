class BuildingLevel < ApplicationRecord
  belongs_to :building_type, optional: true
  has_many :buildings
  FIRST_LEVEL = 1 #Первый уровень
end

