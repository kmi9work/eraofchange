class Troop < ApplicationRecord
  belongs_to :troop_type
  belongs_to :army

  CROSSBOWMEN = 1     #Арбалетчики
  LIGHT_CAVALRY = 2   #Легкая кавалерия
  HEAVY_CAVALRY = 3   #Тяжелая кавалерия
  LIGHT_INFANTRY = 4  #Легкая пехота
  ARCHERS = 5         #Лучники
  MILITIA_MEN = 6     #Ополчение
  FOOT_KIGHTS = 7     #Пешие рыцари
  CANONS = 8          #Пушки
  KNIGHTS = 9         #Рыцари
  STEPPE_ARCHERS = 10 #Степные лучники
  STRELTSY = 11       #Стрельцы
  BATTERING_RAM = 12  #Таран
end
