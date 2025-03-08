cap = SettlementType.create(name: "Столица", params: {"income" => 10000})
town = SettlementType.create(name: "Город", params: {"income" => 5000})
for_cap = SettlementType.create(name: "Иностранный город", params: {"income" => 0})
for_town = SettlementType.create(name: "Иностранная столица", params: {"income" => 10000})

f = File.open('./db/seeds/countries.csv', 'r+')
while str = f.gets
  id, country_name, region_name, city_name, cost = str.split(';')
  country = Country.find_by_name(country_name)
  if country.blank?
    country = Country.create(id: id, name: country_name, params: {"relations" => 0, "embargo" => false})
    RelationItem.add(0, "Ручная правка", country)
  end
  region = Region.find_by_name(region_name)
  if region.blank?
    region = Region.create(name: region_name, country: country)
    PublicOrderItem.add(0, "Ручная правка", region)
  end
  city = Settlement.find_by_name(city_name)
  type = cost.to_i == 10 ? cap : town
  player = nil
  player = @nobles.shuffle.first if country.name == "Русь"
  city ||= Settlement.create(name: city_name, settlement_type: type, region: region, player: player, params: {"open_gate" => false})
end

rel_build = BuildingType.create(name: "Церковь", icon: 'ri-cross-line')
def_build = BuildingType.create(name: "Кремль", icon: 'ri-shield-line')
tra_build = BuildingType.create(name: "Рынок", icon: 'ri-exchange-line')

BuildingLevel.create(level: 1, building_type: rel_build, name: "Часовня", params: {"metropolitan_income" => 1500, "public_order" => 1})
BuildingLevel.create(level: 2, building_type: rel_build, name: "Храм", params: {"metropolitan_income" => 3000, "public_order" => 3})
BuildingLevel.create(level: 3, building_type: rel_build, name: "Монастырь", params: {"metropolitan_income" => 6000, "public_order" => 5})

BuildingLevel.create(level: 1, building_type: def_build, name: "Форт")
BuildingLevel.create(level: 2, building_type: def_build, name: "Крепость")
BuildingLevel.create(level: 3, building_type: def_build, name: "Кремль")

BuildingLevel.create(level: 1, building_type: tra_build, name: "Базар", params: {"income" => 1000})
BuildingLevel.create(level: 2, building_type: tra_build, name: "Рынок", params: {"income" => 2000})
BuildingLevel.create(level: 3, building_type: tra_build, name: "Ярмарка", params: {"income" => 4000})

Building.create(building_level_id: 1, settlement_id: 1)
Building.create(building_level_id: 2, settlement_id: 2)
Building.create(building_level_id: 3, settlement_id: 3)
Building.create(building_level_id: 4, settlement_id: 2)
Building.create(building_level_id: 5, settlement_id: 1)
Building.create(building_level_id: 6, settlement_id: 2)
Building.create(building_level_id: 7, settlement_id: 1)

guild_boss = Job.find_by_name("Глава гульдии")
f = File.open('./db/seeds/pat_merchants.csv', 'r+')
f.gets #headers
while str = f.gets
  name, action, icon, desc, cost, prob, success = str.split(";").map{|i| i.strip}
  PoliticalActionType.create(
    icon: icon, name: name, action: action, job: guild_boss,
    description: desc, cost: cost, probability: prob, success: success)
end

f = File.open('./db/seeds/pat_nobles.csv', 'r+')
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