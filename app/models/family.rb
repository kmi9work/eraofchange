class Family < ApplicationRecord
  has_many :players
  
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
