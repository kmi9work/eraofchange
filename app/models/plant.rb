class Plant < ApplicationRecord
  belongs_to :settlement, optional: true
  belongs_to :economic_subject, polymorphic: true, optional: true
  belongs_to :plant_category, optional: true
  belongs_to :plant_type, optional: true
  # validates :level, numericality: { only_integer: true, message: "В поле Уровень должно быть число" }
  # validates :price, numericality: { only_integer: true, message: "В поле Цена должно быть число" }
  # validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
