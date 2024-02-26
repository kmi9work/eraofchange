class Player < ApplicationRecord
  belongs_to :human, optional: true
  belongs_to :player_type, optional: true
  belongs_to :family, optional: true
  belongs_to :job, optional: true
  belongs_to :guild, optional: true

  has_many :plants
  has_many :settlements
  has_many :armies
  has_many :credits

  has_one :political_action

  #belongs_to :merchant, optional: true
  #validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
