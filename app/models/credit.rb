class Credit < ApplicationRecord
  belongs_to :player, optional: true
  has_many :plants
end
