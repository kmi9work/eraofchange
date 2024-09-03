class PlantType < ApplicationRecord
  belongs_to :plant_category, optional: true
  belongs_to :fossil_type, optional: true
  
  has_many :plant_levels




  FORGE = 13







end
