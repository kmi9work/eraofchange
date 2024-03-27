class Region < ApplicationRecord
	belongs_to :country

	has_many :settlements
	has_many :armies
end
