class ArmySize < ApplicationRecord
  # params: 
  # max_troop (integer) - Максимальное количество отрядов в армии
  # buy_cost (integer) - Стоимость покупки армии
  # renewal_cost (integer) - Стоимость покупки армии

  SMALL = 1    #Малая армия
  MEDIUM = 2   #Средняя армия
  LARGE = 3    #Большая армия
	has_many :armies
end
