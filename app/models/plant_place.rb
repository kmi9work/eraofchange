class PlantPlace < ApplicationRecord
	belongs_to :plant_category, optional: true

	has_many :plants
end
