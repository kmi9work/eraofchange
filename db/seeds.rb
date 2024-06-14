Human.create(name: "Михаил Соколов")
Human.create(name: "Милана Майорова")
Human.create(name: "Александр Осипов")
Human.create(name: "Фёдор Захаров")
Human.create(name: "Никита Некрасов")
Human.create(name: "Саша Никифоров")
Human.create(name: "Марьям Ковалева")
Human.create(name: "Илья Волков ")
Human.create(name: "Мирослава Чернова")
Human.create(name: "Александра Кузьмина")
Human.create(name: "Павел Самсонов")
Human.create(name: "Леон Захаров")


Human.create(name: "Вася Пупкин")
Human.create(name: "Петя Горшков")
Human.create(name: "Вова Распутин")
Human.create(name: "Анна Неболей")
Human.create(name: "Надя Петрова")
Human.create(name: "Саша Никифоров")

PlayerType.create(title: "Купец")
PlayerType.create(title: "Знать")
PlayerType.create(title: "Мудрец")

Family.create(name: "Ивановы")
Family.create(name: "Петровы")
Family.create(name: "Сидоровы")

Job.create(name: "Великий князь")
Job.create(name: "Наследник престола")
Job.create(name: "Посольский дьяк")
Job.create(name: "Казначей")
Job.create(name: "Главный воевода")
Job.create(name: "Митропот Московский и всея Руси")
Job.create(name: "Первый думный боярин")
Job.create(name: "Тайный советник")
Job.create(name: "Дух русского бунта")
Job.create(name: "Глава купеческого приказа")

Player.create(name: "Жопкин", human_id: 1, player_type_id: 2, job_id: 1, family_id: 1, params: {"infuence" => 0} )
Player.create(name: "Борис", human_id: 2, player_type_id: 2, job_id: 2, family_id: 2, params: {"infuence" => 0}  )
Player.create(name: "Манюня", human_id: 3, player_type_id: 2, job_id: 3, family_id: 1, params: {"infuence" => 0}   )
Player.create(name: "Распутин", human_id: 4, player_type_id: 2, job_id: 4, family_id: 2, params: {"infuence" => 0}   )
Player.create(name: "Хренов", human_id: 5, player_type_id: 2, job_id: 5, family_id: 3, params: {"infuence" => 0}   )
Player.create(name: "Образина", human_id: 6, player_type_id: 2, job_id: 6, family_id: 3, params: {"infuence" => 0}   )
Player.create(name: "Распутин", human_id: 7, player_type_id: 2, job_id: 7, family_id: 2, params: {"infuence" => 0}   )
Player.create(name: "Хренов", human_id: 8, player_type_id: 2, job_id: 8, family_id: 3, params: {"infuence" => 0}   )
Player.create(name: "Образина", human_id: 9, player_type_id: 2, job_id: 9, family_id: 3, params: {"infuence" => 0}   )
Player.create(name: "Образина", human_id: 10, player_type_id: 2, job_id: 10, family_id: 3, params: {"infuence" => 0}   )





Guild.create(name: "Забавники")
Guild.create(name: "Каменщики")
Guild.create(name: "Пивовары")

PlantCategory.create(name: "Добывающее")
PlantCategory.create(name: "Перерабатывающее")

Country.create(title: "Русь")
Country.create(title: "Большая орда")
Country.create(title: "Крымское ханство")
Country.create(title: "Казанское")


Region.create(title: "Московское княжество", country_id: 1, params: {"public_order" => 0})
Region.create(title: "Ярославское княжество", country_id: 1, params: {"public_order" => 0})

SettlementType.create(name: "Город", params: {"income" => 8000})
SettlementType.create(name: "Деревня", params: {"income" => 5000})


Settlement.create(name: "Москва", settlement_type_id: 1, region_id: 1, player_id: 1)
Settlement.create(name: "Тверь", settlement_type_id: 1, region_id: 1, player_id: 2)
Settlement.create(name: "Рязань", settlement_type_id: 1, region_id: 1, player_id: 3)
Settlement.create(name: "Хатавки", settlement_type_id: 2, region_id: 1, player_id: 4)
Settlement.create(name: "Гадюкино", settlement_type_id: 2, region_id: 1, player_id: 5)
Settlement.create(name: "Холмищи", settlement_type_id: 2, region_id: 1, player_id: 6)

ArmySize.create(name: "Малая",   level: 1, params:  {renewal_cost: {"gold" => 7000},  buy_cost: {"arms" => 4, "rations" => 5, "armour" => 1, "horses" => 3, "max_troops" => 4}})
ArmySize.create(name: "Средняя", level: 2, params:  {renewal_cost: {"gold" => 12000}, buy_cost: {"arms" => 8, "rations" => 10, "armour" => 2, "horses" => 6, "max_troops" => 8}})
ArmySize.create(name: "Большая", level: 3, params:  {renewal_cost: {"gold" => 16000}, buy_cost: {"arms" => 12, "rations" => 15, "armour" => 4, "horses" => 10, "max_troops" => 12}})

Army.create(region_id: 1, player_id: 1, army_size_id: 1)
Army.create(region_id: 1, player_id: 2, army_size_id: 1)
Army.create(region_id: 1, player_id: 3, army_size_id: 2)
Army.create(region_id: 1, player_id: 4, army_size_id: 2)
Army.create(region_id: 1, player_id: 5, army_size_id: 3)
Army.create(region_id: 1, player_id: 6, army_size_id: 3)

BuildingType.create(title: "Религиозная постройка")
BuildingType.create(title: "Оборонительная постройка")
BuildingType.create(title: "Торговая постройка")
BuildingType.create(title: "Размер гарнизона")

BuildingLevel.create(level: 1, building_type_id: 1, name: "Часовня", params: {"public_order" => 1})
BuildingLevel.create(level: 2, building_type_id: 1, name: "Храм", params: {"public_order" => 3})
BuildingLevel.create(level: 3, building_type_id: 1, name: "Монастырь", params: {"public_order" => 5})

BuildingLevel.create(level: 1, building_type_id: 2, name: "Форт")
BuildingLevel.create(level: 2, building_type_id: 2, name: "Крепость")
BuildingLevel.create(level: 3, building_type_id: 2, name: "Кремль")

BuildingLevel.create(level: 1, building_type_id: 3, name: "Базар", params: {"income" => 1000})
BuildingLevel.create(level: 2, building_type_id: 3, name: "Рынок", params: {"income" => 2000})
BuildingLevel.create(level: 3, building_type_id: 3, name: "Ярмарка", params: {"income" => 4000})

BuildingLevel.create(level: 1, building_type_id: 4, name: "Караул")
BuildingLevel.create(level: 2, building_type_id: 4, name: "Гарнизон")
BuildingLevel.create(level: 3, building_type_id: 4, name: "Казармы")

Building.create(building_level_id: 1, settlement_id: 1)
Building.create(building_level_id: 2, settlement_id: 2)
Building.create(building_level_id: 3, settlement_id: 1)
Building.create(building_level_id: 4, settlement_id: 2)
Building.create(building_level_id: 5, settlement_id: 1)
Building.create(building_level_id: 6, settlement_id: 2)


TroopType.create(title: "Арбалетчики") #CROSSBOWMEN = 1
TroopType.create(title: "Легкая кавалерия") #LIGHT_CAVALRY = 2
TroopType.create(title: "Тяжелая кавалерия")#HEAVY_CAVALRY = 3
TroopType.create(title: "Легкая пехота")  #LIGHT_INFANTRY = 4
TroopType.create(title: "Лучники") # ARCHERS = 5
TroopType.create(title: "Ополчение") #MILITIA_MEN = 6
TroopType.create(title: "Пешие рыцари") #FOOT_KIGHTS = 7
TroopType.create(title: "Пушки") #CANONS = 8
TroopType.create(title: "Рыцари") #KNIGHTS = 9
TroopType.create(title: "Степные лучники") #STEPPE_ARCHERS = 10
TroopType.create(title: "Стрельцы") #STRELTSY = 11
TroopType.create(title: "Таран") #BATTERING_RAM = 12

Troop.create(troop_type_id: 2, is_hired: true, army_id: 1 )
Troop.create(troop_type_id: 3, is_hired: true, army_id: 1 )
Troop.create(troop_type_id: 4, is_hired: true, army_id: 1 )

# Plant.create(name: "Мастерская каменотёса", economic_subject_id: 2,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Трактир", economic_subject_id: 3,economic_subject_type: "Player", plant_category_id: 2, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Player", plant_category_id: 2, level: 1)
# Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 1,economic_subject_type: "Player", plant_category_id: 1, level: 1)
# Plant.create(name: "Каменоломня", economic_subject_id: 2,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 1,economic_subject_type: "Player", plant_category_id: 1, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Player", plant_category_id: 1, level: 1)
# Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Делянка", economic_subject_type: "Guild", plant_category_id: 1, level: 1)

# Plant.create(name: "Лесопилка", economic_subject_id: 1,economic_subject_type: "Player", plant_category_id: 2,plant_type_id: 2, level: 1)

Resource.create(name: "Доски", indentificator: "boards")
Resource.create(name: "Металл", indentificator: "metal")
Resource.create(name: "Каменный кирпич", indentificator: "stone_brick")
Resource.create(name: "Инструменты", indentificator: "tools")
Resource.create(name: "Бревна", indentificator: "beam")
Resource.create(name: "Оружие", indentificator: "weapon")
Resource.create(name: "Драгоценный металл", indentificator: "gems")
Resource.create(name: "Драгоценная руда", indentificator: "gem_ore")
Resource.create(name: "Провизия", indentificator: "food")
Resource.create(name: "Камень", indentificator: "stone")
Resource.create(name: "Mука", indentificator: "flour")
Resource.create(name: "Доспехи", indentificator: "armor")
Resource.create(name: "Зерно", indentificator: "grain")
Resource.create(name: "Лошади", indentificator: "horses")
Resource.create(name: "Mясо", indentificator: "meat")
Resource.create(name: "Pоскошь", indentificator: "luxury")
Resource.create(name: "Железная руда", indentificator: "metal_ore")

PlantCategory.create(name: "Добывающее")
PlantCategory.create(name: "Перерабатывающее")

PlantType.create(name: "Лесопилка", plant_category_id: 2)
PlantType.create(name: "Кузница", plant_category_id: 2)
PlantType.create(name: "Плавильня", plant_category_id: 2)
PlantType.create(name: "Трактир", plant_category_id: 2)
PlantType.create(name: "Мельница", plant_category_id: 2)
PlantType.create(name: "Делянка", plant_category_id: 1)
PlantType.create(name: "Ферма", plant_category_id: 1)
PlantType.create(name: "Железный рудник", plant_category_id: 1)
PlantType.create(name: "Каменоломня", plant_category_id: 1)
PlantType.create(name: "Поля пшеницы", plant_category_id: 1)

PlantLevel.create(level: "1", deposit: "800",   charge: "100", price: {"boards" => 50, "metal" => 10},
                  max_product: {"boards" => 200}, plant_type_id: 1)
PlantLevel.create(level: "2", deposit: "2400",  charge: "300", price: {"boards" => 100, "metal" => 20},
                  max_product: {"boards" => 450}, plant_type_id: 1)
PlantLevel.create(level: "3", deposit: "5600",  charge: "500", price: {"boards" => 150, "stone_brick" => 100, "metal" => 30},
                  max_product: {"boards" => 800}, plant_type_id: 1)

PlantLevel.create(level: "1", deposit: "1500",  charge: "100", price: {"stone_brick" => 50, "metal" => 15, "tools" => 5},
                  max_product: {"tools" => 20}, plant_type_id: 2)
PlantLevel.create(level: "2", deposit: "4500",  charge: "300", price: {"stone_brick" => 100, "metal" => 30, "tools" => 10},
                  max_product: {"tools" => 30, "weapon" => 20}, plant_type_id: 2)
PlantLevel.create(level: "3", deposit: "10500", charge: "500", price: {"stone_brick" => 200, "metal" => 60, "tools" => 20},
                  max_product: {"tools" => 40, "weapon" => 30, "armor" => 20}, plant_type_id: 2)

PlantLevel.create(level: "1", deposit: "1000",  charge: "100", price: {"stone_brick" => 100, "tools" => 1},
                  max_product: {"metal" => 150, "gems" => 75}, plant_type_id: 3)
PlantLevel.create(level: "2", deposit: "3000",  charge: "300", price: {"stone_brick" => 200, "tools" => 2},
                  max_product: {"metal" => 250, "gems" => 150}, plant_type_id: 3)
PlantLevel.create(level: "3", deposit: "6000",  charge: "500", price: {"stone_brick" => 300, "metal" => 30, "tools" => 4},
                  max_product: {"metal" => 450, "gems" => 300}, plant_type_id: 3)

PlantLevel.create(level: "1", deposit: "1200",  charge: "100", price: {"beam"=> 40, "stone_brick" => 70, "metal" => 5},
                  max_product: {"food" => 50}, plant_type_id: 4)
PlantLevel.create(level: "2", deposit: "3600",  charge: "200", price: {"beam"=> 80, "stone_brick" => 140, "metal" => 10},
                  max_product: {"food" => 100}, plant_type_id:4)
PlantLevel.create(level: "3", deposit: "8400",  charge: "300", price: {"beam"=> 140, "stone_brick" => 300, "metal" => 20},
                  max_product: {"food" => 150}, plant_type_id: 4)

PlantLevel.create(level: "1", deposit: "500",  charge: "100", price: {"boards"=> 20, "stone" => 20, "metal" => 5},
                  max_product: {"flour" => 300}, plant_type_id: 5)
PlantLevel.create(level: "2", deposit: "1500",  charge: "300", price: {"boards"=> 40, "stone" => 30, "metal" => 10},
                  max_product: {"flour" => 600}, plant_type_id:5)
PlantLevel.create(level: "3", deposit: "3500",  charge: "500", price: {"boards"=> 100, "stone" => 40, "metal" => 20},
                  max_product: {"flour" => 1000}, plant_type_id: 5)

PlantLevel.create(level: "1", deposit: "800",  charge: "100", price: {"metal" => 10, "tools" => 3},
                  max_product: {"beam" => 100}, plant_type_id: 6)
PlantLevel.create(level: "2", deposit: "2000",  charge: "200", price: {"metal" => 20, "tools" => 5},
                  max_product: {"beam" => 200}, plant_type_id:6)
PlantLevel.create(level: "3", deposit: "3600",  charge: "300", price: {"metal" => 30, "tools" => 7},
                  max_product: {"beam" => 300}, plant_type_id: 6)

PlantLevel.create(level: "1", deposit: "1200",  charge: "100", price: {"boards" => 100, "grain" => 50},
                  max_product: {"meat" => 100}, plant_type_id: 7)
PlantLevel.create(level: "2", deposit: "2600",  charge: "200", price: {"boards" => 120, "grain" => 60},
                  max_product: {"meat" => 150, "horses" => 6}, plant_type_id:7)
PlantLevel.create(level: "3", deposit: "4400",  charge: "300", price: {"boards" => 150, "grain" => 80},
                  max_product: {"meat" => 200, "horses" =>12}, plant_type_id: 7)

PlantLevel.create(level: "1", deposit: "2000",   charge: "200", price: {"boards" => 100, "metal" => 10, "tools" => 8},
                  max_product: {"metal_ore" => 250}, plant_type_id: 8)
PlantLevel.create(level: "2", deposit: "5500",  charge: "400", price: {"boards" => 200, "metal" => 20, "tools" => 10},
                  max_product: {"metal_ore" => 600}, plant_type_id: 8)
PlantLevel.create(level: "3", deposit: "10500",  charge: "600", price: {"boards" => 300, "metal" => 40, "tools" => 12},
                  max_product: {"metal_ore" => 1000}, plant_type_id: 8)

PlantLevel.create(level: "1", deposit: "1200",   charge: "100", price: {"boards" => 50, "metal" => 10, "tools" => 4},
                  max_product: {"stone" => 100}, plant_type_id: 9)
PlantLevel.create(level: "2", deposit: "3400",  charge: "200", price: {"boards" => 100, "metal" => 20, "tools" => 6},
                  max_product: {"stone" => 200}, plant_type_id: 9)
PlantLevel.create(level: "3", deposit: "6900",  charge: "300", price: {"boards" => 150, "metal" => 40, "tools" => 8},
                  max_product: {"stone" => 350}, plant_type_id: 9)

PlantLevel.create(level: "1", deposit: "600",   charge: "100", price: {"grain" => 50, "tools" => 2},
                  max_product: {"grain" => 100}, plant_type_id: 10)
PlantLevel.create(level: "2", deposit: "1500",  charge: "200", price: {"grain" => 60, "tools" => 4},
                  max_product: {"grain" => 200}, plant_type_id: 10)
PlantLevel.create(level: "3", deposit: "2700",  charge: "300", price: {"grain" => 70, "tools" => 6},
                  max_product: {"grain" => 300}, plant_type_id: 10)

PoliticalActionType.create(title: "Благотворительность", action: "charity")
PoliticalActionType.create(title: "Подстрекательство к бунту", action: 'sedition')
