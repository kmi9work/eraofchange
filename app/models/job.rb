class Job < ApplicationRecord
	has_and_belongs_to_many :players
	has_many :technologies
  has_many :political_action_types
  has_many :political_actions

  GRAND_PRINCE = 1 #Великий князь
  METROPOLITAN = 2 #Митрополит
  POSOL = 3
  KAZNACHEI = 4
  VOEVODA = 5
  TAINIY = 6
  ZODCHIY = 7
  OKOLNICHY = 8
  SPIRIT = 9
  GUILD_BOSS = 10

  ZODCHIY_BONUS = 2
  GRAND_PRINCE_BONUS = 2
  OKOLNICHY_BONUS = 2
  TAINIY_BONUS = 3
  VOEVODA_BONUS = 4
  KAZNACHEI_BONUS = 5
  POSOL_BONUS = 4

  METROPOLITAN_PINE = -1
end
