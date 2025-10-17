class Guild < ApplicationRecord
  audited
  
  has_many :players
  has_many :caravans
  has_many :plants, :as => :economic_subject,
                    :inverse_of => :economic_subject
  #validates :name, presence: true { message: "Поле Имя должно быть заполнено" }
end
