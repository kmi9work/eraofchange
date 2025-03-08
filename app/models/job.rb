class Job < ApplicationRecord
	has_many :players
	has_many :ideologist_technologies
  has_many :political_action_types

  GRAND_PRINCE = 1 #Великий князь
  METROPOLITAN = 2 #Митрополит

end
