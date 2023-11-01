class Player < ApplicationRecord
  belongs_to :merchant, optional: true
  validates :name, presence: true
end
