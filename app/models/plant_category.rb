class PlantCategory < ApplicationRecord
	has_many :plant_types
	has_many :plant_places
end
