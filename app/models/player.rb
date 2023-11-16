class Player < ApplicationRecord
  belongs_to :merchant, optional: true
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
