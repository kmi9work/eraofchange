# Player(id: integer, name: string, merchant_id: integer, created_at: datetime, updated_at: datetime)
# Plant(id: integer, name: string, category: string, price: integer, level: string, location: string, economic_subject_id: integer, economic_subject_type: string, settlement_id: integer, created_at: datetime, updated_at: datetime)
# Guild(id: integer, name: string, created_at: datetime, updated_at: datetime)
# Family(id: integer, name: string, created_at: datetime, updated_at: datetime)
# Merchant(id: integer, name: string, plant_id: integer, family_id: integer, guild_id: integer, created_at: datetime, updated_at: datetime)


Player.create(name: "Жопкин", merchant_id: 1 )
Player.create(name: "Борис", merchant_id: 2)
Player.create(name: "Манюня", merchant_id: 3)
Player.create(name: "Жопкин", merchant_id: 4 )
Player.create(name: "Борис", merchant_id: 5)
Player.create(name: "Манюня", merchant_id: 6)

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

Plant.create(name: "Лесопилка")
Plant.create(name: "Каменоломня")
Plant.create(name: "Пивная")
Plant.create(name: "Рудник")
Plant.create(name: "Золотой рудник")
Plant.create(name: "Делянка")