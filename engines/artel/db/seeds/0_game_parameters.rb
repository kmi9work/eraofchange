current_year = 1
GameParameter.create(id: current_year, name: "Текущий год", identificator: "current_year", value: "1", params:
{"state_expenses" => false})

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(name: "Ставка кредита (%)", identificator: "credit_size", value: "20")
GameParameter.create(name: "Срок кредита (лет)", identificator: "credit_term", value: "3")

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(id: GameParameter::TIMER, name: "Расписание", identificator: "schedule", 	 value: "1", params: [])

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(id: GameParameter::SCREEN, name: "Экран", identificator: "screen", 	 value: GameParameter::DEFAULT_SCREEN, params: [])

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(id: GameParameter::RESULTS, name: "Результаты купцов", identificator: "results", 	 
												 value: "0", params: {display: "merchPlaceholder", merchant_results: []})


ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(name: "Количество лет", identificator: "years_count", value: "5", params: {})

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(
  name: "Настройки ограбления караванов", 
  identificator: "caravan_robbery_settings",
  value: "0",
  params: {
    robbery_by_year: {},
    protected_guilds_by_year: {},
    arrived_count_by_year: {},
    robbed_count_by_year: {}
  }
)

GameParameter.create(name: "Количество караванов в гильдии", identificator: "caravans_per_guild", value: "3", params: {})

GameParameter.create(name: "Длительные эффекты", identificator: "lingering_effects", value: 0, params: [])

GameParameter.create(name: "Мобильный помощник", identificator: "mobile_helper", value: 0, params: [])


