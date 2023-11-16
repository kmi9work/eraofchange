class Family < ApplicationRecord
  has_many :merchants
  validates :name, presence: true
end
