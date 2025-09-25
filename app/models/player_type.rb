class PlayerType < ApplicationRecord
  has_many :players

  MERCHANT = 1  # Купец
  NOBLE = 2     # Знать
  SAGE = 3      # Мудрец
  REBEL = 4     # Дух бунта
  REBEL_NAME = "Дух бунта"

end
