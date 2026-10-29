class Job < ApplicationRecord
  audited
  
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
  # Бонусы должностей за присоединённую ЗЕМЛЮ (регион), не за государство:
  # решение заказчика — Посольский дьяк получает 7, Великий князь 5 за каждую
  # присоединённую землю (см. Region#captured_by).
  GRAND_PRINCE_BONUS = 5
  OKOLNICHY_BONUS = 2
  TAINIY_BONUS = 3
  VOEVODA_BONUS = 4
  KAZNACHEI_BONUS = 5
  POSOL_BONUS = 7

  METROPOLITAN_PINE = -1
  # Штраф Воеводе за каждую разбитую армию своего государства (решение заказчика:
  # победителю +4 за каждую разбитую армию противника, проигравшему −1 за каждую).
  VOEVODA_PENALTY = -1

  # Игроки указанного государства на этой должности: справочник должностей общий,
  # «свой совет» = свои игроки этого государства на тех же должностях.
  def council_players(country = Country.current)
    return players.none if country.nil?

    players.where(country_id: country.id)
  end

  def council_player_ids(country = Country.current)
    council_players(country).pluck(:id)
  end

  def holders_names(country = Country.current)
    council_players(country).pluck(:name)
  end
end
