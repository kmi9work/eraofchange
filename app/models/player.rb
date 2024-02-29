class Player < ApplicationRecord
  belongs_to :family, optional: true
  belongs_to :guild, optional: true
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
