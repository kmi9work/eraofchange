class PlantCategory < ApplicationRecord
	belongs_to :plant, optional: true
end
