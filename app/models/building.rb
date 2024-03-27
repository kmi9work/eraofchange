class Building < ApplicationRecord
  belongs_to :building_level, optional: true
  belongs_to :settlement, optional: true
end
