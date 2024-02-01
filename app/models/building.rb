class Building < ApplicationRecord
  belongs_to :building_level
  belongs_to :settlement
end
