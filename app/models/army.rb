class Army < ApplicationRecord
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  belongs_to :army_size, optional: true

  has_many :troops, dependent: :destroy
end
