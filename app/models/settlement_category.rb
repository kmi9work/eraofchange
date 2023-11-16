class SettlementCategory < ApplicationRecord
	has_many :settlements
	validates :name, presence: { message: "Поле Название должно быть заполнено" }
end
