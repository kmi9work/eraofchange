class Army < ApplicationRecord
  belongs_to :region
  belongs_to :player
  belongs_to :army_size
end
