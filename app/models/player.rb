class Player < ApplicationRecord
  belongs_to :family, optional: true
  belongs_to :guild, optional: true
  belongs_to :player_type, optional: true

  has_many :credits
  has_many :political_actions
  has_many :plants, :as => :economic_subject,
                    :inverse_of => :economic_subject
  
  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
end
