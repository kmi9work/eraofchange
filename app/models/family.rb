class Family < ApplicationRecord
  has_many :merchants
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }

end
