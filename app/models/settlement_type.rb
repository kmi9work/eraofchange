class SettlementType < ApplicationRecord
	has_many :settlements
	#validates :name, presence: { message: "Поле Название должно быть заполнено" }

  TOWN = 1 # Город
  VILLAGE = 2 # Деревня
end
