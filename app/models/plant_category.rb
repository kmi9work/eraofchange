class PlantCategory < ApplicationRecord
	has_many :plant_types
	has_many :plant_places

	EXTRACTIVE = 1
	PROCESSING = 2



end
