class BuildingLevel < ApplicationRecord
  # params:
  # public_order (integer) - Влияние на общественный порядок (у церкви - положительное)

  belongs_to :building_type, optional: true
  has_many :buildings
  FIRST_LEVEL = 1 #Первый уровень
  MAX_LEVEL = 3
end

