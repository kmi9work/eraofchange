

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


PlayerType.create(title: "Купец")
PlayerType.create(title: "Знать")
PlayerType.create(title: "Мудрец")


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





Family.create(name: "Ивановы")
Family.create(name: "Петровы")
Family.create(name: "Сидоровы")

Guild.create(name: "Забавники")
Guild.create(name: "Каменщики")
Guild.create(name: "Пивовары")

PlantCategory.create(name: "Добывающее")
PlantCategory.create(name: "Перерабатывающее")

Country.create(title: "Русь")
Country.create(title: "Большая орда")
Country.create(title: "Крымское ханство")
Country.create(title: "Казанское")


Region.create(title: "Московское княжество", country_id: 1, params: {"pub_order" => 0,
"boards" => 200,
"stone" => 200,
"arms" => 10,
"luxiry" => 5,
"rations" => 20})

SettlementType.create(name: "Город", params: {"income" => 8000})
SettlementType.create(name: "Деревня", params: {"income" => 5000})


Settlement.create(name: "Москва", settlement_type_id: 1, region_id: 1, player_id: 1)
Settlement.create(name: "Тверь", settlement_type_id: 1, region_id: 1, player_id: 2)
Settlement.create(name: "Рязань", settlement_type_id: 1, region_id: 1, player_id: 3)
Settlement.create(name: "Хатавки", settlement_type_id: 2, region_id: 1, player_id: 4)
Settlement.create(name: "Гадюкино", settlement_type_id: 2, region_id: 1, player_id: 5)
Settlement.create(name: "Холмищи", settlement_type_id: 2, region_id: 1, player_id: 6)


ArmySize.create(name: "Малая", level: 1, params:    {"gold" => 7000, "arms" => 4, "rations" => 5, "armour" => 1, "horses" => 3, "max_troop" => 4})
ArmySize.create(name: "Средняя", level: 2, params:  {"gold" => 12000, "arms" => 8, "rations" => 10, "armour" => 2, "horses" => 6, "max_troop" => 8})
ArmySize.create(name: "Большая", level: 3, params:  {"gold" => 16000, "arms" => 12, "rations" => 15, "armour" => 4, "horses" => 10, "max_troop" => 12})

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



BuildingLevel.create(level: 1, building_type_id: 1, name: "Часовня", params: {"pub_order" => 1})
BuildingLevel.create(level: 2, building_type_id: 1, name: "Храм", params: {"pub_order" => 3})
BuildingLevel.create(level: 3, building_type_id: 1, name: "Монастырь", params: {"pub_order" => 5})


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



# Plant.create(name: "Лесопилка", 
# Plant.create(name: "Мастерская каменотёса", economic_subject_id: 2,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Трактир", economic_subject_id: 3,economic_subject_type: "Merchant", plant_category_id: 2, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Merchant", plant_category_id: 2, level: 1)
# Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 1,economic_subject_type: "Merchant", plant_category_id: 1, level: 1)
# Plant.create(name: "Каменоломня", economic_subject_id: 2,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 1,economic_subject_type: "Merchant", plant_category_id: 1, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Merchant", plant_category_id: 1, level: 1)
# Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Делянка", economic_subject_type: "Guild", plant_category_id: 1, level: 1)

# Plant.create(name: "Лесопилка", economic_subject_id: 1,economic_subject_type: "Merchant", plant_category_id: 2,plant_type_id: 2, level: 1)

# PlantType.create(name: "Лесопилка")
# PlantType.create(name: "Трактир")
# PlantType.create(name: "Рудник")



# # PlantType.create(name: "Рудник")
# # PlantType.create(name: "Золотой рудник")
# # PlantType.create(name: "Каменоломня")
# # PlantType.create(name: "Делянка")

# # PlantType.create(name: "Мастерская каменотёса")
# # PlantType.create(name: "Рудник")



# SettlementType.create(name: "Город")
# SettlementType.create(name: "Деревня")

# Settlement.create(name: "Москва", settlement_type_id: 1)
# Settlement.create(name: "Тверь", settlement_type_id: 1)
# Settlement.create(name: "Рязань", settlement_type_id: 1)
# Settlement.create(name: "Хатавки", settlement_type_id: 2)
# Settlement.create(name: "Гадюкино", settlement_type_id: 2)
# Settlement.create(name: "Холмищи", settlement_type_id: 2)

# Resource.create(name: "Бревна", price: "1")
# Resource.create(name: "Руда", price: "100")
# Resource.create(name: "Зерно", price: "10")
