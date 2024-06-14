class Country < ApplicationRecord
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
  
	has_many :regions
end
