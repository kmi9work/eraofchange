class TroopType < ApplicationRecord
	has_many :troops, dependent: :destroy

  MILITIA = 1
  HEAVY_MILITIA = 2
  CAVALRY = 3
end
