class TroopType < ApplicationRecord
	has_many :troops, dependent: :destroy
end
