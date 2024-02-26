class Job < ApplicationRecord
	has_many :players
	belongs_to :ideologist_technology
end
