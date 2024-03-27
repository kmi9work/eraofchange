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

Player.create(name: "Забава", family_id: 1, guild_id: 1)
Player.create(name: "Верещага", family_id: 1, guild_id: 1)
Player.create(name: "Любава", family_id: 2, guild_id: 2)
Player.create(name: "Добрыня", family_id: 2, guild_id: 2)
Player.create(name: "Купава", family_id: 3, guild_id: 3)
Player.create(name: "Алтын", family_id: 3, guild_id: 3)

PlantType.create(name: "Лесопилка", plant_category_id: 2)
PlantType.create(name: "Кузница", plant_category_id: 2)
PlantType.create(name: "Железный рудник", plant_category_id: 1)
PlantType.create(name: "Каменоломня", plant_category_id: 1)
PlantType.create(name: "Делянка", plant_category_id: 1)

Family.create(name: "Ивановы")
Family.create(name: "Петровы")
Family.create(name: "Сидоровы")

Guild.create(name: "Забавники")
Guild.create(name: "Каменщики")
Guild.create(name: "Пивовары")

PlantCategory.create(name: "Добывающее")
PlantCategory.create(name: "Перерабатывающее")

SettlementCategory.create(name: "Город")
SettlementCategory.create(name: "Деревня")

Settlement.create(name: "Москва", settlement_category_id: 1)
Settlement.create(name: "Тверь", settlement_category_id: 1)
Settlement.create(name: "Рязань", settlement_category_id: 1)
Settlement.create(name: "Хатавки", settlement_category_id: 2)
Settlement.create(name: "Гадюкино", settlement_category_id: 2)
Settlement.create(name: "Холмищи", settlement_category_id: 2)

Resource.create(name: "Бревна", price: "1")
Resource.create(name: "Руда", price: "100")
Resource.create(name: "Зерно", price: "10")


# bt1 = BuildingType.create(name: "Церковь")
# bt2 = BuildingType.create(name: "Гарнизон")
# bt3 = BuildingType.create(name: "Рынок")
# bt4 = BuildingType.create(name: "Укрепления")

# bl1 = BuildingLevel.create(level: 1, price: {gold: 1000}, params: {income: 2000}, building_type: bt3)
# bl2 = BuildingLevel.create(level: 2, price: {gold: 2000}, params: {income: 4000}, building_type: bt3)
# bl3 = BuildingLevel.create(level: 3, price: {gold: 4000}, params: {income: 8000}, building_type: bt3)

# b1 = Building.create(comment: "Рынок второго уровня", building_level: bl2)
# b1 = Building.create(comment: "Рынок третьего уровня", building_level: bl3)

# puts "Проверка"
# puts b1.comment
# puts "#{b1.building_level.building_type.name} #{b1.building_level.level} уровня"

# puts b2.comment
# puts "#{b2.building_level.building_type.name} #{b2.building_level.level} уровня"

# puts bt3.name
# bt3.building_levels.each do |bl| 
# 	puts bl.level
# 	bl.buildings.each do |b|
# 		puts b.comment
# 	end
# end

