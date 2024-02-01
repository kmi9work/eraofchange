class Troop < ApplicationRecord
  belongs_to :troop_type
  belongs_to :army
end
