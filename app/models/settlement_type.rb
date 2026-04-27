class SettlementType < ApplicationRecord
	has_many :settlements
	#validates :name, presence: { message: "Поле Название должно быть заполнено" }

  CAPITAL = 1 # Столица
  TOWN = 2 # Город
  TYPE_REGION = 3 # Город
  CAP_REGION = 4 # Город
end
