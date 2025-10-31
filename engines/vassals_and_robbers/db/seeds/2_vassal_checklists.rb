puts "=== Vassals and Robbers: Создание чек-листов вассалитета ==="

# Чек-лист для Новгорода
novgorod_checklist = VassalsAndRobbers::Checklist.find_or_create_by(vassal_country_id: Country::NOVGOROD) do |checklist|
  checklist.conditions = {
    "conditions" => [
      {
        "type" => "army_power",
        "requirement" => 15,
        "description" => "Суммарная мощь армии"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::NOVGOROD,
        "requirement" => 1,
        "description" => "Уровень отношений с Новгородом"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::LIVONIAN,
        "requirement" => 0,
        "description" => "Уровень отношений с Ливонией"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::SWEDEN,
        "requirement" => 0,
        "description" => "Уровень отношений со Швецией"
      },
      {
        "type" => "alliance",
        "target_country_id" => Country::NOVGOROD,
        "alliance_type" => "Наступательный союз",
        "description" => "Альянс с Новгородом"
      },
      {
        "type" => "technology",
        "technology_ids" => [Technology::OVERSEAS_TRADE, Technology::MOSCOW_THIRD_ROME],
        "description" => "Заморская торговля, Москва — Третий Рим"
      },
      {
        "type" => "trade_turnover",
        "target_country_id" => Country::LIVONIAN,
        "requirement" => 3,
        "description" => "Уровень товарооборота с Ливонией"
      },
      {
        "type" => "plant",
        "plant_type_name" => "Поле пшеницы",
        "level" => 3,
        "description" => "Поля пшеницы 3 уровня"
      },
      {
        "type" => "plant",
        "plant_type_name" => "Ферма",
        "level" => 3,
        "description" => "Ферма 3 уровня"
      },
      {
        "type" => "plant",
        "plant_type_name" => "Трактир",
        "level" => 3,
        "description" => "Трактир 3 уровня"
      }
    ]
  }
end
puts "Создан чек-лист для Новгорода"

# Чек-лист для Твери
tver_checklist = VassalsAndRobbers::Checklist.find_or_create_by(vassal_country_id: Country::TVER) do |checklist|
  checklist.conditions = {
    "conditions" => [
      {
        "type" => "army_power",
        "requirement" => 12,
        "description" => "Суммарная мощь армии"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::TVER,
        "requirement" => 1,
        "description" => "Уровень отношений с Тверью"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::LITHUANIA,
        "requirement" => 0,
        "description" => "Уровень отношений с Литвой"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::NOVGOROD,
        "requirement" => 0,
        "description" => "Уровень отношений с Новгородом"
      },
      {
        "type" => "alliance",
        "target_country_id" => Country::LITHUANIA,
        "alliance_type" => "Пакт о ненападении",
        "description" => "Альянс с Литвой"
      },
      {
        "type" => "alliance",
        "target_country_id" => Country::TVER,
        "alliance_type" => "Оборонный союз",
        "description" => "Альянс с Тверью"
      },
      {
        "type" => "trade_turnover",
        "target_country_id" => Country::LITHUANIA,
        "requirement" => 2,
        "description" => "Объем товарооборота с Литвой"
      }
    ]
  }
end
puts "Создан чек-лист для Твери"

# Чек-лист для Перми
perm_checklist = VassalsAndRobbers::Checklist.find_or_create_by(vassal_country_id: Country::PERMIAN) do |checklist|
  checklist.conditions = {
    "conditions" => [
      {
        "type" => "army_power",
        "requirement" => 8,
        "description" => "Суммарная мощь армии"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::PERMIAN,
        "requirement" => 2,
        "description" => "Отношения с Пермью"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::KAZAN,
        "requirement" => 2,
        "description" => "Отношения с Казанью"
      },
      {
        "type" => "alliance",
        "target_country_id" => Country::KAZAN,
        "alliance_type" => "Оборонный союз",
        "description" => "Альянс с Казанью"
      },
      {
        "type" => "alliance",
        "target_country_id" => Country::PERMIAN,
        "alliance_type" => "Оборонный союз",
        "description" => "Альянс с Пермью"
      },
      {
        "type" => "technology",
        "technology_ids" => [Technology::CRAFTSMEN, Technology::BALLISTICS],
        "description" => "Ремесловые люди, Баллистика"
      },
      {
        "type" => "trade_turnover",
        "target_country_id" => Country::KAZAN,
        "requirement" => 2,
        "description" => "Минимальный объем товарооборота с Казанью"
      },
      {
        "type" => "plant",
        "plant_type_name" => "Плавильня",
        "level" => 3,
        "description" => "Плавильня 3 уровня"
      },
      {
        "type" => "public_order",
        "region_id" => Region::VOLOGODSKOE_KNYAZESTVO,
        "requirement" => 5,
        "description" => "Уровень Общественного порядка в Вологодском княжестве"
      },
      {
        "type" => "building",
        "settlement_name" => "Нижний Новгород",
        "building_type" => "Кремль",
        "level" => 1,
        "description" => "Нижний Новгород — Крепость 1 уровня"
      },
      {
        "type" => "building",
        "settlement_name" => "Арзамас",
        "building_type" => "Кремль",
        "level" => 1,
        "description" => "Арзамас — Крепость 1 уровня"
      }
    ]
  }
end
puts "Создан чек-лист для Перми"

# Чек-лист для Рязани
ryazan_checklist = VassalsAndRobbers::Checklist.find_or_create_by(vassal_country_id: Country::RYAZAN) do |checklist|
  checklist.conditions = {
    "conditions" => [
      {
        "type" => "relations",
        "target_country_id" => Country::RUS,
        "requirement" => 1,
        "description" => "Отношения с Москвой"
      },
      {
        "type" => "relations",
        "target_country_id" => Country::HORDE,
        "requirement" => 0,
        "description" => "Отношения с Ордой"
      },
      {
        "type" => "alliance",
        "target_country_id" => Country::HORDE,
        "alliance_type" => "Пакт о ненападении",
        "description" => "Альянс с Ордой"
      },
      {
        "type" => "trade_turnover",
        "target_country_id" => Country::HORDE,
        "requirement" => 2,
        "description" => "Объем товарооборота с Ордой"
      },
      {
        "type" => "trade_turnover",
        "target_country_id" => Country::CRIMEA,
        "requirement" => 1,
        "description" => "Объем товарооборота с Крымским ханством"
      },
      {
        "type" => "public_order",
        "region_id" => Region::MOSCOW_KNYAZESTVO,
        "requirement" => 6,
        "description" => "Уровень Общественного порядка"
      },
      {
        "type" => "public_order",
        "region_id" => Region::NIGERODSKOE_KNYAZESTVO,
        "requirement" => 4,
        "description" => "Уровень Общественного порядка"
      }
    ]
  }
end
puts "Создан чек-лист для Рязани"

puts "=== Чек-листы вассалитета созданы ==="

