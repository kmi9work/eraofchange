class Plant < ApplicationRecord
  belongs_to :settlement, optional: true
  belongs_to :economic_subject, polymorphic: true, optional: true
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
  validates :price, numericality: { only_integer: true, message: "В поле Цена должно быть число" }
  validates :level, numericality: { only_integer: true, message: "В поле Уровень должно быть число" }
end
