class Settlement < ApplicationRecord
  belongs_to :settlement_type, optional: true
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  has_many :plant_places
  has_many :buildings
  validates :name, presence: { message: "Поле Название должно быть заполнено" }
end
