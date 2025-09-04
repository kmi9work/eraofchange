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

GameParameter.create(id: GameParameter::RESULTS, name: "Результаты купцов", identificator: "results", 	 value: "0", params: {})



ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(id: GameParameter::RESULTS + 1, name: "тест", identificator: "test", 	 value: "0", params: [])

