class BuildingType < ApplicationRecord
	has_many :building_levels

  RELIGIOUS = 1 #"Религиозная постройка"
  DEFENCE = 2 #"Обронительная постройка"
  TRADE = 3 #"Торговая постройка"
  GUARDING_TROOP = 4  #"Размер постройка"
end
