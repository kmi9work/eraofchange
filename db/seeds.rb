# Player(id: integer, name: string, merchant_id: integer, created_at: datetime, updated_at: datetime)
# Plant(id: integer, name: string, category: string, price: integer, level: string, settlement_id: string, economic_subject_id: integer, economic_subject_type: string, settlement_id: integer, created_at: datetime, updated_at: datetime)
# Guild(id: integer, name: string, created_at: datetime, updated_at: datetime)
# Family(id: integer, name: string, created_at: datetime, updated_at: datetime)
# Merchant(id: integer, name: string, plant_id: integer, family_id: integer, guild_id: integer, created_at: datetime, updated_at: datetime)


Player.create(name: "Жопкин", merchant_id: 1 )
Player.create(name: "Борис", merchant_id: 2)
Player.create(name: "Манюня", merchant_id: 3)
Player.create(name: "Распутин", merchant_id: 4 )
Player.create(name: "Хренов", merchant_id: 5)
Player.create(name: "Образина", merchant_id: 6)

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
Guild.create(name: "Каменьщики")
Guild.create(name: "Пивовары")

Plant.create(name: "Лесопилка", economic_subject_id: 1,economic_subject_type: "Merchant")
Plant.create(name: "Каменоломня", economic_subject_id: 2,economic_subject_type: "Guild")
Plant.create(name: "Пивная", economic_subject_id: 3,economic_subject_type: "Merchant")
Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild")
Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Merchant")
Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild")

Plant.create(name: "Рудник", economic_subject_id: 1,economic_subject_type: "Merchant")
Plant.create(name: "Каменоломня", economic_subject_id: 2,economic_subject_type: "Guild")
Plant.create(name: "Золотой рудник", economic_subject_id: 1,economic_subject_type: "Merchant")
Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild")
Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Merchant")
Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild")



Settlement.create(name: "Москва", category: "Город")
Settlement.create(name: "Тверь", category: "Город")
Settlement.create(name: "Рязань", category: "Город")
Settlement.create(name: "Хатавки", category: "Город")
Settlement.create(name: "Гадюкино", category: "Город")
Settlement.create(name: "Холмищи", category: "Город")

