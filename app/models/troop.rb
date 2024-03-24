class Troop < ApplicationRecord
  belongs_to :troop_type, optional: true
  belongs_to :army, optional: true
end
