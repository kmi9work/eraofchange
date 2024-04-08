# Player(id: integer, name: string, merchant_id: integer, created_at: datetime, updated_at: datetime)
# Plant(id: integer, name: string, category: string, price: integer, level: string, settlement_id: string, economic_subject_id: integer, economic_subject_type: string, settlement_id: integer, created_at: datetime, updated_at: datetime)
# Guild(id: integer, name: string, created_at: datetime, updated_at: datetime)
# Family(id: integer, name: string, created_at: datetime, updated_at: datetime)
# Merchant(id: integer, name: string, plant_id: integer, family_id: integer, guild_id: integer, created_at: datetime, updated_at: datetime)


# Player.destroy_all
# Merchant.destroy_all
# Family.destroy_all
# Guild.destroy_all
# Plant.destroy_all
# Settlement.destroy_all


Human.create(name: "Вася Пупкин")
Human.create(name: "Петя Горшков")
Human.create(name: "Вова Распутин")
Human.create(name: "Анна Неболей")
Human.create(name: "Надя Петрова")
Human.create(name: "Саша Никифоров")

PlayerType.create(title: "Купец")
PlayerType.create(title: "Знать")
PlayerType.create(title: "Мудрец")


Player.create(name: "Жопкин", human_id: 1, player_type_id: 1, job_id: 1, family_id: 1 )
Player.create(name: "Борис", human_id: 2, player_type_id: 1, job_id: 1, family_id: 2 )
Player.create(name: "Манюня", human_id: 3, player_type_id: 2, job_id: 2, family_id: 1  )
Player.create(name: "Распутин", human_id: 4, player_type_id: 2, job_id: 3, family_id: 2  )
Player.create(name: "Хренов", human_id: 5, player_type_id: 3, job_id: 4, family_id: 3  )
Player.create(name: "Образина", human_id: 6, player_type_id: 3, job_id: 5, family_id: 3  )


Job.create(name: "Князь")
Job.create(name: "Казначей")
Job.create(name: "Посольский дьяк")
Job.create(name: "Окольничей")
Job.create(name: "Митрополит")
Job.create(name: "Воевада")


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


Region.create(title: "Московское княжество", country_id: 1)

SettlementType.create(name: "Город")
SettlementType.create(name: "Деревня")


Settlement.create(name: "Москва", settlement_type_id: 1, region_id: 1, player_id: 1)
Settlement.create(name: "Тверь", settlement_type_id: 1, region_id: 1, player_id: 2)
Settlement.create(name: "Рязань", settlement_type_id: 1, region_id: 1, player_id: 3)
Settlement.create(name: "Хатавки", settlement_type_id: 2, region_id: 1, player_id: 4)
Settlement.create(name: "Гадюкино", settlement_type_id: 2, region_id: 1, player_id: 5)
Settlement.create(name: "Холмищи", settlement_type_id: 2, region_id: 1, player_id: 6)


ArmySize.create(name: "Малая", level: 1)
ArmySize.create(name: "Средняя", level: 2)
ArmySize.create(name: "Большая", level: 3)

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



BuildingLevel.create(level: 1, building_type_id: 1, name: "Часовня")
BuildingLevel.create(level: 2, building_type_id: 1, name: "Храм")
BuildingLevel.create(level: 3, building_type_id: 1, name: "Монастырь")



BuildingLevel.create(level: 1, building_type_id: 2, name: "Форт")
BuildingLevel.create(level: 2, building_type_id: 2, name: "Крепость")
BuildingLevel.create(level: 3, building_type_id: 2, name: "Кремль")



BuildingLevel.create(level: 1, building_type_id: 3, name: "Базар")
BuildingLevel.create(level: 2, building_type_id: 3, name: "Рынок")
BuildingLevel.create(level: 3, building_type_id: 3, name: "Ярмарка")


BuildingLevel.create(level: 1, building_type_id: 4, name: "Караул")
BuildingLevel.create(level: 2, building_type_id: 4, name: "Гарнизон")
BuildingLevel.create(level: 3, building_type_id: 4, name: "Казармы")



Building.create(building_level_id: 1, settlement_id: 1)
Building.create(building_level_id: 2, settlement_id: 2)
Building.create(building_level_id: 3, settlement_id: 1)
Building.create(building_level_id: 4, settlement_id: 2)
Building.create(building_level_id: 5, settlement_id: 1)
Building.create(building_level_id: 6, settlement_id: 2)


TroopType.create(title: "Легкая пехота")
TroopType.create(title: "Конница")
TroopType.create(title: "Рыцари")
TroopType.create(title: "Пушки")

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

Plant.create(name: "Лесопилка", economic_subject_id: 1,economic_subject_type: "Merchant", plant_category_id: 2,plant_type_id: 2, level: 1)

PlantType.create(name: "Лесопилка")
PlantType.create(name: "Трактир")
PlantType.create(name: "Рудник")



# PlantType.create(name: "Рудник")
# PlantType.create(name: "Золотой рудник")
# PlantType.create(name: "Каменоломня")
# PlantType.create(name: "Делянка")

# PlantType.create(name: "Мастерская каменотёса")
# PlantType.create(name: "Рудник")



SettlementType.create(name: "Город")
SettlementType.create(name: "Деревня")

Settlement.create(name: "Москва", settlement_type_id: 1)
Settlement.create(name: "Тверь", settlement_type_id: 1)
Settlement.create(name: "Рязань", settlement_type_id: 1)
Settlement.create(name: "Хатавки", settlement_type_id: 2)
Settlement.create(name: "Гадюкино", settlement_type_id: 2)
Settlement.create(name: "Холмищи", settlement_type_id: 2)

Resource.create(name: "Бревна", price: "1")
Resource.create(name: "Руда", price: "100")
Resource.create(name: "Зерно", price: "10")
