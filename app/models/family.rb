class Family < ApplicationRecord
  audited

  has_many :players, dependent: :nullify
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
