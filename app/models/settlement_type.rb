class SettlementType < ApplicationRecord
	has_many :settlements
	#validates :name, presence: { message: "Поле Название должно быть заполнено" }

  CAPITAL = 1 # Столица
  TOWN = 2 # Город
end
