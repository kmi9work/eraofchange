class SettlementType < ApplicationRecord
	belongs_to :region, optional: true
	has_many :settlements
	validates :name, presence: { message: "Поле Название должно быть заполнено" }
end
