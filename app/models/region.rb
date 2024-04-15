class Region < ApplicationRecord
	belongs_to :country

	has_many :settlements
	has_many :armies

	@@base_public_order = -4 #Для примера

	def public_order
		public_order = 0
		self.settlements.each do |settle|
			settle.buildings.each do |build|
				if build.building_level.building_type == BuildingType.find_by_id(Settlement::RELIGIOUS_BUILDING)
					public_order = public_order + build.building_level.params["pub_order"]
				end
			end

		end
		public_order = @@base_public_order + public_order
	end







end
