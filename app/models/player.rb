class Player < ApplicationRecord
  # params:
  # infuence (integer) - Влияние

  belongs_to :human, optional: true
  belongs_to :player_type, optional: true
  belongs_to :family, optional: true
  belongs_to :job, optional: true
  belongs_to :guild, optional: true

  has_many :plants, :as => :economic_subject,
           :inverse_of => :economic_subject
  has_many :settlements
  has_many :armies
  has_many :credits
  has_many :political_actions

  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
