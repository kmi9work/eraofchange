town = SettlementType.create(name: "Город", params: {"income" => 5000})
cap = SettlementType.create(name: "Столица", params: {"income" => 10000})
type_region = SettlementType.create(name: "Земля", params: {"income" => 10000})
cap_region = SettlementType.create(name: "Столичная земля", params: {"income" => 15000})
xz = SettlementType.create(name: "ХЗ", params: {"income" => 0})

rel_build = BuildingType.create(name: "Церковь", icon: 'ri-cross-line')
def_build = BuildingType.create(name: "Кремль", icon: 'ri-shield-line')
tra_build = BuildingType.create(name: "Рынок", icon: 'ri-exchange-line')

rels = [
  BuildingLevel.create(level: 1, building_type: rel_build, name: "Часовня", params: {"metropolitan_income" => 1500, "public_order" => 1, "metropolitan_influence" => 1}),
  BuildingLevel.create(level: 2, building_type: rel_build, name: "Храм", params: {"metropolitan_income" => 3000, "public_order" => 3, "metropolitan_influence" => 3}),
  BuildingLevel.create(level: 3, building_type: rel_build, name: "Монастырь", params: {"metropolitan_income" => 6000, "public_order" => 6, "metropolitan_influence" => 6})
]

defs = [
  BuildingLevel.create(level: 1, building_type: def_build, name: "Форт", params: {"influence" => 1}),
  BuildingLevel.create(level: 2, building_type: def_build, name: "Крепость", params: {"influence" => 4}),
  BuildingLevel.create(level: 3, building_type: def_build, name: "Кремль", params: {"influence" => 7})
]

tras = [
  BuildingLevel.create(level: 1, building_type: tra_build, name: "Базар", params: {"income" => 1000}),
  BuildingLevel.create(level: 2, building_type: tra_build, name: "Рынок", params: {"income" => 2000}),
  BuildingLevel.create(level: 3, building_type: tra_build, name: "Ярмарка", params: {"income" => 4000})
]

f = File.open('./db/seeds/countries.csv', 'r+')
f.gets #Заголовки


levels = [
  { level: 0, threshold: 0, name: ""},
  { level: 1, threshold: 10000, name: "Низкий"},
  { level: 2, threshold: 30000, name: "Средний"},
  { level: 3, threshold: 70000, name: "Высокий"}
]

# Маппинг коротких имен стран
short_names_map = {
  'Большая Орда' => 'Орда',
  'Ливонский орден' => 'Ливония',
  'Королевство Швеция' => 'Швеция',
  'Великое княжество Литовское' => 'Литва',
  'Казанское ханство' => 'Казань',
  'Крымское ханство' => 'Крым',
  'Великий Новгород' => 'Новгород',
}

# Маппинг названий файлов изображений флагов (латиница, без пробелов)
flag_image_map = {
  1 => 'rus',           # Русь
  2 => 'horde',         # Большая Орда
  3 => 'livonian',      # Ливонский орден
  4 => 'sweden',        # Королевство Швеция
  5 => 'lithuania',     # Великое княжество Литовское
  6 => 'kazan',         # Казанское ханство
  7 => 'crimea',        # Крымское ханство
  8 => 'perm',          # Пермь
  9 => 'vyatka',        # Вятка
  10 => 'ryazan',       # Рязань
  11 => 'tver',         # Тверь
  12 => 'novgorod',     # Великий Новгород
}

po_values = [1, 0, -1, -1, *Array.new(100, 0)] #Общественный порядок в начале
while str = f.gets
  id, country_name, region_name, city_name, cost_type, player_name, def_level, tra_level, rel_level, relations, embargo, way = str.split(';').map(&:strip)
  country = Country.find_by_name(country_name)
  if country.blank?
    short_name = short_names_map[country_name] || country_name
    flag_image_name = flag_image_map[id.to_i]
    country = Country.create(id: id, name: country_name, short_name: short_name, flag_image_name: flag_image_name, params: {"embargo" => embargo.presence&.to_i, "relation_points" => 0, "level_thresholds" =>  levels})
    RelationItem.add(relations.to_i, "Ручная правка", country)
  end
  region = Region.find_by_name(region_name)
  if region.blank?
    region = Region.create(name: region_name, country: country, way: way)
    PublicOrderItem.add(po_values[region.id - 1], "Ручная правка", region)
  end
  city = Settlement.find_by_name(city_name)
  type = case cost_type.to_i
  when 1
    town
  when 2
    cap
  when 3
    type_region
  when 4
    cap_region
  else
    xz
  end
  player = Player.find_by_name(player_name)
  city ||= Settlement.create(name: city_name, settlement_type: type, region: region, player: player, params: {"open_gate" => false})
  if def_level.strip.present?
    Building.create(building_level: defs[def_level.to_i - 1], settlement: city)
  end
  if tra_level.strip.present?
    Building.create(building_level: tras[tra_level.to_i - 1], settlement: city)
  end
  if rel_level.strip.present?
    Building.create(building_level: rels[rel_level.to_i - 1], settlement: city)
  end
end

guild_boss = Job.find_by_name("Глава гульдии")
f = File.open('./db/seeds/pat_merchants.csv', 'r+')
f.gets #headers
while str = f.gets
  name, action, icon, desc, cost, prob, success = str.split(";").map{|i| i.strip}
  PoliticalActionType.create(
    icon: icon, name: name, action: action, job: guild_boss,
    description: desc, cost: cost, probability: prob, success: success)
end

pat_path = ENV['APP_VERSION'] == 'core' ? './db/seeds/pat_nobles.csv' : './engines/vassals_and_robbers/db/seeds/pat_nobles_vassals.csv'

f = File.open(pat_path, 'r+')
f.gets #headers
while str = f.gets
  job_name, name, action, icon, desc, prob, cost, success, failure = str.split(";").map{|i| i.strip}
  job = Job.find_by_name(job_name)
  PoliticalActionType.create(
    icon: icon, name: name, action: action, job: job,
    description: desc, cost: cost, probability: prob, 
    success: success, failure: failure)
end

f = File.open('./db/seeds/technologies.csv', 'r+')
f.gets #headers
while str = f.gets
  name, description = str.split(";").map{|i| i.strip}
  t = Technology.create(name: name, description: description, params: {'opened' => 0})
  TechnologyItem.add(0, "Изменить значение", t)
end












# Settlement.create(name: "Азак", settlement_type_id: cap.id, region_id: 1, player_id: 2, params: {"open_gate" => false})
# Settlement.create(name: "Алексин", settlement_type_id: cap.id, region_id: 1, player_id: 3, params: {"open_gate" => false})
# Settlement.create(name: "Арзамас", settlement_type_id: cap.id, region_id: 1, player_id: 4, params: {"open_gate" => false})
# Settlement.create(name: "Бахчисарай", settlement_type_id: cap.id, region_id: 1, player_id: 5, params: {"open_gate" => false})
# Settlement.create(name: "Белоозеро", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Биляр", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Брацлав", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Брянск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Булгар", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Варзуга", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Великий Новгород", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Великий Устюг", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Вильно", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Виндава", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Вологда", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Волок Ламский", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Выборг", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Дерпт", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Джулат", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Елец", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Житомир", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Ислам-Керман", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Казань", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Канев", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Каргополь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Кемь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Киев", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Кичмента", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Койгородок", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Коломна", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Кострома", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Котельнич", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Ладога", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Маджар", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Минск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Можайск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Москва", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Мохши", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Мстиславль", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Муром", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Нижний Новгород", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Новгород-Северский", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Нюслотт", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Нюхча", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Одоев", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Орлец", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Орша", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Переславль-Рязанский", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Пермь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Псков", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Ревель", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Рига", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Руза", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Рыльск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Самар", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Сарай бату", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Сарай-Бекке", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Сарайчик", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Смолненск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Стародуб", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Суздаль", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Тверь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Торопец", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Тула", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Туров", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Увек", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Углич", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Умба", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Усогорск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Усть-Вымь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Усть-Цильма", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Фарах-Керман", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Хаджитархан", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Хлынов", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Холмогоры", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Чаллы", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Чердынь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Чернигов", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Чимги-тура", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
# Settlement.create(name: "Ярославль", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
