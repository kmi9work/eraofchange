class PlantPlace < ApplicationRecord
  belongs_to :plant_category, optional: true
  belongs_to :settlement, optional: true

  has_many :plants
  has_and_belongs_to_many :fossil_types
end
