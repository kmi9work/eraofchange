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


Human.create(name: "Вася")
Human.create(name: "Петя")
Human.create(name: "Женя")
Human.create(name: "Анна")
Human.create(name: "Надя")
Human.create(name: "Саша")

PlayerType.create(title: "Купец")
PlayerType.create(title: "Знать")

Player.create(name: "Жопкин", human_id: 1, player_type_id: 1 )
Player.create(name: "Борис", human_id: 2, player_type_id: 1 )
Player.create(name: "Манюня", human_id: 3, player_type_id: 1 )
Player.create(name: "Распутин", human_id: 4, player_type_id: 2  )
Player.create(name: "Хренов", human_id: 5, player_type_id: 2 )
Player.create(name: "Образина", human_id: 6, player_type_id: 2 )





Merchant.create(name: "Забава", plant_id:1, family_id: 1, guild_id:1)
Merchant.create(name: "Верещага", plant_id:2, family_id:2, guild_id:2)
Merchant.create(name: "Любава", plant_id:3, family_id:3, guild_id:3)
Merchant.create(name: "Добрыня", plant_id:4, family_id:1, guild_id:1)
Merchant.create(name: "Купава", plant_id:5, family_id:2, guild_id:2)
Merchant.create(name: "Алтын", plant_id:6, family_id:3, guild_id:3)


Family.create(name: "Ивановы")
Family.create(name: "Петровы")
Family.create(name: "Сидоровы")

Guild.create(name: "Забавники")
Guild.create(name: "Каменщики")
Guild.create(name: "Пивовары")

PlantCategory.create(name: "Добывающее")
PlantCategory.create(name: "Перерабатывающее")

# Plant.create(name: "Лесопилка", 

Plant.create(name: "Мастерская каменотёса", settlement_id: 1)
Plant.create(name: "Трактир", economic_subject_id: 3,economic_subject_type: "Merchant", plant_category_id: 2, level: 1)
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