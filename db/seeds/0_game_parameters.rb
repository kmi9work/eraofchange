current_year = 1
GameParameter.create(id: current_year, name: "Текущий год", identificator: "current_year", value: "1", params:
{"state_expenses" => false})

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(name: "Ставка кредита (%)", identificator: "credit_size", value: "20")
GameParameter.create(name: "Срок кредита (лет)", identificator: "credit_term", value: "3")

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')

GameParameter.create(id: GameParameter::TIMER, name: "Продолжительность цикла", identificator: "cycle_time", 	 value: "3600", params: [])

ActiveRecord::Base.connection.reset_pk_sequence!('game_parameters')