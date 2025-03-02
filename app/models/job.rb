class Job < ApplicationRecord
	has_many :players
	has_many :ideologist_technologies

  GRAND_PRINCE = 1 #Великий князь
  METROPOLITAN = 2 #Митрополит

end
