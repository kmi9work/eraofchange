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

BuildingType.create(title: "Церковь")
BuildingType.create(title: "Храм")
BuildingType.create(title: "Рынок")
BuildingType.create(title: "Форт")

BuildingLevel.create(level: 1, building_type_id: 1)
BuildingLevel.create(level: 2, building_type_id: 1)
BuildingLevel.create(level: 3, building_type_id: 1)

Building.create(building_level_id: 1, settlement_id: 1)
Building.create(building_level_id: 2, settlement_id: 1)
Building.create(building_level_id: 3, settlement_id: 1)

TroopType.create(title: "Легкая пехота")
TroopType.create(title: "Конница")
TroopType.create(title: "Рыцари")
TroopType.create(title: "Пушки")

Troop.create(troop_type_id: 2, is_hired: true, army_id: 1 )
Troop.create(troop_type_id: 3, is_hired: true, army_id: 1 )
Troop.create(troop_type_id: 4, is_hired: true, army_id: 1 )

Settlement.create(name: "Москва", settlement_type_id: 1)
Settlement.create(name: "Тверь", settlement_type_id: 1)
Settlement.create(name: "Рязань", settlement_type_id: 1)
Settlement.create(name: "Хатавки", settlement_type_id: 2)
Settlement.create(name: "Гадюкино", settlement_type_id: 2)
Settlement.create(name: "Холмищи", settlement_type_id: 2)

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

