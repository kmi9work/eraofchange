class Job < ApplicationRecord
	has_many :players
	has_many :ideologist_technologies
end
