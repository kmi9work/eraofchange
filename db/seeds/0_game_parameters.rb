puts 'Creating GameParameter\'s'
GameParameter.create(name: "Текущий год", identificator: "current_year", value: "1", params:
{"state_expenses" => false})

GameParameter.create(name: "Ставка кредита (%)", identificator: "credit_size", value: "20")
GameParameter.create(name: "Срок кредита (лет)", identificator: "credit_term", value: "3")

GameParameter.create(name: "Расписание", identificator: "schedule", value: "1", params: [])

GameParameter.create(name: "Экран", identificator: "screen", value: GameParameter::DEFAULT_SCREEN, params: [])

GameParameter.create(name: "Результаты купцов", identificator: "results", 	 
												 value: "0", params: {display: "merchPlaceholder", merchant_results: []})

GameParameter.create(name: "Количество лет", identificator: "years_count", value: "5", params: {})

GameParameter.create(
  name: "Настройки ограбления караванов", 
  identificator: "caravan_robbery_settings",
  value: "0",
  params: {
    "robbery_by_year" => {},
    "protected_guilds_by_year" => {},
    "arrived_count_by_year" => {},
    "robbed_count_by_year" => {}
  }
)

GameParameter.create(name: "Количество караванов в гильдии", identificator: "caravans_per_guild", value: "3", params: {})

GameParameter.create(name: "Максимальные отношения для торговых очков", identificator: "max_relations_for_trade_points", value: "2", params: {})

GameParameter.create(name: "Длительные эффекты", identificator: "lingering_effects", value: 0, params: [])

GameParameter.create(name: "Мобильный помощник", identificator: "mobile_helper", value: 0, params: [])

GameParameter.create(
  name: "Расписание Государя",
  identificator: "sovereign_schedule",
  value: "0",
  params: [
    {
      "id" => 1,
      "name" => "Общее расписание",
      "items" => [
        {"id" => 1, "identificator" => "Инструтаж", "start" => "13:00", "finish" => "13:45", "type" => "play"},
        {"id" => 2, "identificator" => "Игра", "start" => "13:45", "finish" => "16:25", "type" => "play"},
        {"id" => 3, "identificator" => "Обсуждение", "start" => "16:25", "finish" => "17:00", "type" => "play"}
      ]
    },
    {
      "id" => 2,
      "name" => "Команда №1",
      "items" => [
        {"id" => 1, "identificator" => "Инструтаж", "start" => "13:00", "finish" => "13:45", "type" => "play"},
        {"id" => 2, "identificator" => "Год 1. Фаза Стратегии", "start" => "13:45", "finish" => "14:15", "type" => "play"},
        {"id" => 3, "identificator" => "Год 1. Фаза Действия", "start" => "14:15", "finish" => "14:25", "type" => "play"},
        {"id" => 4, "identificator" => "Год 1. Фаза Подготовки", "start" => "14:25", "finish" => "14:30", "type" => "play"},
        {"id" => 5, "identificator" => "Год 2. Фаза Стратегии", "start" => "14:30", "finish" => "14:45", "type" => "play"},
        {"id" => 6, "identificator" => "Год 2. Фаза Действия", "start" => "14:45", "finish" => "14:55", "type" => "play"},
        {"id" => 7, "identificator" => "Год 2. Фаза Подготовки", "start" => "14:55", "finish" => "15:00", "type" => "play"},
        {"id" => 8, "identificator" => "Год 3. Фаза Стратегии", "start" => "15:00", "finish" => "15:15", "type" => "play"},
        {"id" => 9, "identificator" => "Год 3. Фаза Действия", "start" => "15:15", "finish" => "15:25", "type" => "play"},
        {"id" => 10, "identificator" => "Год 3. Фаза Подготовки", "start" => "15:25", "finish" => "15:30", "type" => "play"},
        {"id" => 11, "identificator" => "Год 4. Фаза Стратегии", "start" => "15:30", "finish" => "15:45", "type" => "play"},
        {"id" => 12, "identificator" => "Год 4. Фаза Действия", "start" => "15:45", "finish" => "15:55", "type" => "play"},
        {"id" => 13, "identificator" => "Год 4. Фаза Подготовки", "start" => "15:55", "finish" => "16:00", "type" => "play"},
        {"id" => 14, "identificator" => "Год 5. Фаза Стратегии", "start" => "16:00", "finish" => "16:15", "type" => "play"},
        {"id" => 15, "identificator" => "Год 5. Фаза Действия", "start" => "16:15", "finish" => "16:25", "type" => "play"}
      ]
    },
    {
      "id" => 3,
      "name" => "Команда №2",
      "items" => [
        {"id" => 1, "identificator" => "Инструтаж", "start" => "13:00", "finish" => "13:45", "type" => "play"},
        {"id" => 2, "identificator" => "Год 1. Фаза Стратегии", "start" => "13:45", "finish" => "14:00", "type" => "play"},
        {"id" => 3, "identificator" => "Год 1. Фаза Действия", "start" => "14:00", "finish" => "14:10", "type" => "play"},
        {"id" => 4, "identificator" => "Год 1. Фаза Подготовки", "start" => "14:10", "finish" => "14:15", "type" => "play"},
        {"id" => 5, "identificator" => "Год 2. Фаза Стратегии", "start" => "14:15", "finish" => "14:30", "type" => "play"},
        {"id" => 6, "identificator" => "Год 2. Фаза Действия", "start" => "14:30", "finish" => "14:40", "type" => "play"},
        {"id" => 7, "identificator" => "Год 2. Фаза Подготовки", "start" => "14:40", "finish" => "14:45", "type" => "play"},
        {"id" => 8, "identificator" => "Год 3. Фаза Стратегии", "start" => "14:45", "finish" => "15:00", "type" => "play"},
        {"id" => 9, "identificator" => "Год 3. Фаза Действия", "start" => "15:00", "finish" => "15:10", "type" => "play"},
        {"id" => 10, "identificator" => "Год 3. Фаза Подготовки", "start" => "15:10", "finish" => "15:15", "type" => "play"},
        {"id" => 11, "identificator" => "Год 4. Фаза Стратегии", "start" => "15:15", "finish" => "15:30", "type" => "play"},
        {"id" => 12, "identificator" => "Год 4. Фаза Действия", "start" => "15:30", "finish" => "15:40", "type" => "play"},
        {"id" => 13, "identificator" => "Год 4. Фаза Подготовки", "start" => "15:40", "finish" => "15:45", "type" => "play"},
        {"id" => 14, "identificator" => "Год 5. Фаза Стратегии", "start" => "15:45", "finish" => "16:00", "type" => "play"},
        {"id" => 15, "identificator" => "Год 5. Фаза Действия", "start" => "16:00", "finish" => "16:10", "type" => "play"},
        {"id" => 16, "identificator" => "Год 5. Ожидание действия противников", "start" => "16:10", "finish" => "16:25", "type" => "play"}
      ]
    }
  ]
)

