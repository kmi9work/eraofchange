class PlantPlace < ApplicationRecord
	belongs_to :settlement
	belongs_to :plant_category
end
