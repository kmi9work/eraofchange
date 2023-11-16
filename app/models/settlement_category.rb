class SettlementCategory < ApplicationRecord
	has_many :settlements
	validates :name, presence: { message: "Поле Название должно быть заполнено" }
	validates :name, format: { with: /\А[а-яA-Я]+\я/, message: "В поле Название не допустимо использовать числа" }
end
