class FossilType < ApplicationRecord
	has_many :plant_types
	has_and_belongs_to_many :plant_places

end
