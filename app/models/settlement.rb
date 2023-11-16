class Settlement < ApplicationRecord
  belongs_to :settlement_category, optional: true
  has_many :plants
  validates :name, presence: { message: "Поле Название должно быть заполнено" }
end
