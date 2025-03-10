class Job < ApplicationRecord
	has_and_belongs_to_many :players
	has_many :technologies
  has_many :political_action_types
  has_many :political_actions

  GRAND_PRINCE = 1 #Великий князь
  METROPOLITAN = 2 #Митрополит

end
