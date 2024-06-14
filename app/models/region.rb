class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок
	belongs_to :country

	has_many :settlements
	has_many :armies
end
