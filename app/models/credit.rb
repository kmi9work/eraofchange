class Credit < ApplicationRecord
  audited

  belongs_to :player, optional: true
  has_many :plants
end
