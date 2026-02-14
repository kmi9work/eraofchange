
guild_names = ["Забавники", "Каменщики","Пивовары"]

guild_names.each {|name| Guild.create(name: name, params: {caravan_protected: []})} 
  


dob = PlantCategory.create(name: "Добывающее", is_extractive: true)
per = PlantCategory.create(name: "Перерабатывающее", is_extractive: false)

# Типы месторождений
timber_fossil = FossilType.create(name: "Строевой лес")
pasture_fossil = FossilType.create(name: "Пастбище")
fertile_land_fossil = FossilType.create(name: "Плодородная земля")
stone_fossil = FossilType.create(name: "Камень")
iron_ore_fossil = FossilType.create(name: "Железная руда")
gem_ore_fossil = FossilType.create(name: "Драгоценная руда")

delyan = 1
PlantType.create(id: delyan, name: "Делянка", plant_category: dob, fossil_type: timber_fossil)

farm = 2
PlantType.create(id: farm, name: "Ферма", plant_category: dob, fossil_type: pasture_fossil)

field = 3
PlantType.create(id: field, name: "Поле пшеницы", plant_category: dob, fossil_type: fertile_land_fossil)

quarry = 4
PlantType.create(id: quarry, name: "Каменоломня", plant_category: dob, fossil_type: stone_fossil)


iron_mine = 5
PlantType.create(id: iron_mine, name: "Железный рудник", plant_category: dob, fossil_type: iron_ore_fossil)


gold_mine = 6
PlantType.create(id: gold_mine, name: "Драгоценный рудник", plant_category: dob, fossil_type: gem_ore_fossil)





PlantLevel.create(level: "1", deposit: "1000", price: {"timber" => 200, "grain" => 150},
                  formulas: [{from:         [],
                            to:           [{identificator: "timber", count: 100}],
                            max_product:  [{identificator: "timber", count: 100}]}],
                  plant_type_id: delyan)

PlantLevel.create(level: "2", deposit: "1700", price: {"timber" => 50, "grain" => 150},
                  formulas: [{from:         [],
                            to:           [{identificator: "timber", count: 200}],
                            max_product:  [{identificator: "timber", count:  200}]}],
                  plant_type_id: delyan)

PlantLevel.create(level: "3", deposit: "4100", price: {"timber" => 75, "grain" => 200, "tools" => 30},
                  formulas: [{from:         [],
                            to:           [{identificator: "timber", count: 500}],
                            max_product:  [{identificator: "timber", count:  500}]}],
                  plant_type_id: delyan)


PlantLevel.create(level: "1", deposit: "1700", price: {"grain" => 500, "timber" => 100},
                  formulas: [{from:         [],
                            to:           [{identificator: "meat", count: 75}],
                            max_product:  [{identificator: "timber", count:  100}]}],
                  plant_type_id: farm)

PlantLevel.create(level: "2", deposit: "5000", price: {"grain" => 1000, "timber" => 200},
                  formulas: [{from:         [],
                            to:           [{identificator: "meat", count: 150}, {identificator: "horses", count: 22}],
                            max_product:  [{identificator: "meat", count: 150}, {identificator: "horses", count: 22}]}],
                  plant_type_id: farm)

PlantLevel.create(level: "3", deposit: "10700", price: {"grain" => 1500, "timber" => 200, "tools" => 30},
                  formulas: [{from:         [],
                            to:           [{identificator: "meat", count: 375}, {identificator: "horses", count: 55}],
                            max_product:  [{identificator: "meat", count: 375}, {identificator: "horses", count: 55}]}],
                  plant_type_id: farm)



PlantLevel.create(level: "1", deposit: "1200", price: {"grain" => 900, "stone" => 20},
                  formulas: [{from:         [],
                            to:           [{identificator: "grain", count: 450}],
                            max_product:  [{identificator: "grain", count: 450}]}],
                  plant_type_id: field)

PlantLevel.create(level: "2", deposit: "1900", price: {"grain" => 200, "stone" => 20},
                  formulas: [{from:         [],
                            to:           [{identificator: "grain", count: 900}],
                            max_product:  [{identificator: "grain", count: 900}]}],
                  plant_type_id: field)

PlantLevel.create(level: "3", deposit: "4300", price: {"grain" => 300, "stone" => 30, "metal" => 60},
                  formulas: [{from:         [],
                            to:           [{identificator: "grain", count: 2300}],
                            max_product:  [{identificator: "grain", count: 2300}]}],
                  plant_type_id: field)



PlantLevel.create(level: "1", deposit: "1200", price: {"stone" => 120, "timber" => 30},
                  formulas: [{from:         [],
                            to:           [{identificator: "stone", count: 60}],
                            max_product:  [{identificator: "stone", count: 60}]}],
                  plant_type_id: quarry)

PlantLevel.create(level: "2", deposit: "2000", price: {"stone" => 30, "timber" => 30},
                  formulas: [{from:         [],
                            to:           [{identificator: "stone", count: 120}],
                            max_product:  [{identificator: "stone", count: 120}]}],
                  plant_type_id: quarry)

PlantLevel.create(level: "3", deposit: "3400", price: {"stone" => 40, "timber" => 50, "food" => 15},
                  formulas: [{from:         [],
                            to:           [{identificator: "stone", count: 300}],
                            max_product:  [{identificator: "stone", count: 300}]}],
                  plant_type_id: quarry)



PlantLevel.create(level: "1", deposit: "1800", price: {"stone_brick" => 200, "timber" => 70},
                  formulas: [{from:         [],
                            to:           [{identificator: "metal_ore", count: 200}],
                            max_product:  [{identificator: "metal_ore", count: 200}]}],
                  plant_type_id: iron_mine)

PlantLevel.create(level: "2", deposit: "3000", price: {"stone_brick" => 70, "timber" => 70},
                  formulas: [{from:         [],
                            to:           [{identificator: "metal_ore", count: 400}],
                            max_product:  [{identificator: "metal_ore", count: 400}]}],
                  plant_type_id: iron_mine)

PlantLevel.create(level: "3", deposit: "5200", price: {"stone_brick" => 120, "timber" => 50, "food" => 20},
                  formulas: [{from:         [],
                            to:           [{identificator: "metal_ore", count: 1000}],
                            max_product:  [{identificator: "metal_ore", count: 1000}]}],
                  plant_type_id: iron_mine)


PlantLevel.create(level: "1", deposit: "2000", price: {"stone" => 70, "boards" => 200},
                  formulas: [{from:         [],
                            to:           [{identificator: "gem_ore", count: 200}],
                            max_product:  [{identificator: "gem_ore", count: 200}]}],
                  plant_type_id: gold_mine)

PlantLevel.create(level: "2", deposit: "3400", price: {"stone" => 40, "boards" => 150},
                  formulas: [{from:         [],
                            to:           [{identificator: "gem_ore", count: 400}],
                            max_product:  [{identificator: "gem_ore", count: 400}]}],
                  plant_type_id: gold_mine)

PlantLevel.create(level: "3", deposit: "5500", price: {"stone" => 60, "boards" => 70, "metal" => 50},
                  formulas: [{from:         [],
                            to:           [{identificator: "gem_ore", count: 1000}],
                            max_product:  [{identificator: "gem_ore", count: 1000}]}],
                  plant_type_id: gold_mine)








saw_mill = 7
#Лесопилка
PlantType.create(id: saw_mill, name: "Лесопилка", plant_category: per)
#Мастерская каменотеса
stonemason = 8
PlantType.create(id: stonemason, name: "Мастерская каменотеса", plant_category: per)
#Мельница
mill = 9
PlantType.create(id: mill, name: "Мельница", plant_category: per)

#ювелирная мастерская
jeweller = 10
PlantType.create(id: jeweller, name: "Ювелирная мастерская", plant_category: per)



tavern = 11
PlantType.create(id: tavern, name: "Трактир", plant_category: per)

foundry = 12
PlantType.create(id: foundry, name: "Плавильня", plant_category: per)




forge = 13
PlantType.create(id: forge, name: "Кузница", plant_category: per)




#Лесопилка
PlantLevel.create(level: "1", deposit: "1000", price: {"gold" => 1200},
                  formulas: [{from:         [{identificator: "timber", count: 2}],
                            to:           [{identificator: "boards", count: 3}],
                            max_product:  [{identificator: "boards", count: 300}]}],
                  plant_type_id: saw_mill)


PlantLevel.create(level: "2", deposit: "2200", price: {"stone_brick" => 100, "food" => 10},
                  formulas: [{from:         [{identificator: "timber", count: 1}],
                            to:           [{identificator: "boards", count: 2}],
                            max_product:  [{identificator: "boards", count: 600}]}],
                  plant_type_id: saw_mill)


PlantLevel.create(level: "3", deposit: "5100", price: {"stone_brick" => 200, "food" => 30},
                  formulas: [{from:         [{identificator: "timber", count: 1}],
                            to:           [{identificator: "boards", count: 3}],
                            max_product:  [{identificator: "boards", count: 1500}]}],
                  plant_type_id: saw_mill)


#Мастерская каменотёса
PlantLevel.create(level: "1", deposit: "1000", price: {"gold" => 1200},
                  formulas: [{from:         [{identificator: "stone", count: 1}],
                            to:           [{identificator: "stone_brick", count: 2}],
                            max_product:  [{identificator: "stone_brick", count: 240}]}],
                  plant_type_id: stonemason)


PlantLevel.create(level: "2", deposit: "2200", price: {"flour" => 150, "metal" => 40},
                  formulas: [{from:         [{identificator: "stone", count: 1}],
                            to:           [{identificator: "stone_brick", count: 3}],
                            max_product:  [{identificator: "stone_brick", count: 540}]}],
                  plant_type_id: stonemason)


PlantLevel.create(level: "3", deposit: "5100", price: {"flour" => 200, "metal" => 130},
                  formulas: [{from:         [{identificator: "stone", count: 1}],
                            to:           [{identificator: "stone_brick", count: 4}],
                            max_product:  [{identificator: "stone_brick", count: 1200}]}],
                  plant_type_id: stonemason)


#Мельница
PlantLevel.create(level: "1", deposit: "1000", price: {"gold" => 1200},
                  formulas: [{from:         [{identificator: "grain", count: 3}],
                            to:           [{identificator: "flour", count: 1}],
                            max_product:  [{identificator: "flour", count: 300}]}],
                  plant_type_id: mill)

PlantLevel.create(level: "2", deposit: "2500", price: {"boards" => 150, "tools" => 15},
                  formulas: [{from:         [{identificator: "grain", count: 2}],
                            to:           [{identificator: "flour", count: 1}],
                            max_product:  [{identificator: "flour", count: 675}]}],
                  plant_type_id: mill)


PlantLevel.create(level: "3", deposit: "6000", price: {"boards" => 300, "tools" => 40},
                  formulas: [{from:         [{identificator: "grain", count: 3}],
                            to:           [{identificator: "flour", count: 2}],
                            max_product:  [{identificator: "flour", count: 1500}]}],
                  plant_type_id: mill)



#Ювелирная мастерская
PlantLevel.create(level: "1", deposit: "2400", price: {"gold" => 3000},
                  formulas: [{from:         [{identificator: "gems", count: 4}],
                            to:           [{identificator: "luxury", count: 1}],
                            max_product:  [{identificator: "luxury", count: 40}]}],
                  plant_type_id: jeweller)

PlantLevel.create(level: "2", deposit: "4700", price: {"stone_brick" => 200, "food" => 15},
                  formulas: [{from:         [{identificator: "gems", count: 3}],
                            to:           [{identificator: "luxury", count: 1}],
                            max_product:  [{identificator: "luxury", count: 100}]}],
                  plant_type_id: jeweller)

PlantLevel.create(level: "3", deposit: "9200", price: {"stone_brick" =>400, "food" => 30},
                  formulas: [{from:         [{identificator: "gems", count: 2}],
                            to:           [{identificator: "luxury", count: 1}],
                            max_product:  [{identificator: "luxury", count: 250}]}],
                  plant_type_id: jeweller)


#Таверна
PlantLevel.create(level: "1", deposit: "1500", price: {"gold" => 1500},
                  formulas: [{from:         [{identificator: "meat", count: 3}, {identificator: "flour", count: 6}],
                            to:           [{identificator: "food", count: 1}],
                            max_product:  [{identificator: "food", count: 50}]}],
                  plant_type_id: tavern)

PlantLevel.create(level: "2", deposit: "1500", price: {"flour" => 200, "metal" => 30},
                  formulas: [{from:         [{identificator: "meat", count: 2}, {identificator: "flour", count: 4}],
                            to:           [{identificator: "food", count: 1}],
                            max_product:  [{identificator: "food", count: 150}]}],
                  plant_type_id: tavern)

PlantLevel.create(level: "3", deposit: "1500", price: {"flour" => 400, "metal" => 80},
                  formulas: [{from:         [{identificator: "meat", count: 3}, {identificator: "flour", count: 6}],
                            to:           [{identificator: "food", count: 2}],
                            max_product:  [{identificator: "food", count: 250}]}],
                  plant_type_id: tavern)




#Плавильня
PlantLevel.create(level: "1", deposit: "1600", price: {"gold" => 2000},
                  formulas: [
                              { from:         [{identificator: "metal_ore", count: 4}],
                                to:           [{identificator: "metal", count: 1}],
                                max_product:  [{identificator: "metal", count: 100}]},
                              {from:         [{identificator: "gem_ore", count: 5}],
                                to:           [{identificator: "gems", count: 1}],
                                max_product:  [{identificator: "gems", count: 80}]}
                            ],
                  plant_type_id: foundry)

PlantLevel.create(level: "2", deposit: "3400", price: {"boards" => 250, "tools" => 10},
                  formulas: [
                              { from:         [{identificator: "metal_ore", count: 3}],
                                to:           [{identificator: "metal", count: 1}],
                                max_product:  [{identificator: "metal", count: 200}]},
                              { from:         [{identificator: "gem_ore", count: 3}],
                                to:           [{identificator: "gems", count: 1}],
                                max_product:  [{identificator: "gems", count: 200}]}
                            ],
                  plant_type_id: foundry)

PlantLevel.create(level: "3", deposit: "7800", price: {"boards" => 500, "tools" => 35},
                  formulas: [
                              { from:         [{identificator: "metal_ore", count: 2}],
                                to:           [{identificator: "metal", count: 1}],
                                max_product:  [{identificator: "metal", count: 500}]},
                              { from:         [{identificator: "gem_ore", count: 2}],
                                to:           [{identificator: "gems", count: 1}],
                                max_product:  [{identificator: "gems", count: 500}]}
                            ],
                            plant_type_id: foundry)


#Кузница
PlantLevel.create(level: "1", deposit: "1500", price: {"stone_brick" => 50, "metal" => 15},
                  formulas: [
                              { from:         [{identificator: "boards", count: 6}, {identificator: "metal", count: 1}],
                                to:           [{identificator: "tools", count: 1}],
                                max_product:  [{identificator: "tools", count: 20}]}
                            ],
                  plant_type_id: forge)

PlantLevel.create(level: "2", deposit: "4500", price: {"stone_brick" => 50, "metal" => 30, "tools" => 10},
                  formulas: [
                              { from:         [{identificator: "boards", count: 6}, {identificator: "metal", count: 1}],
                                to:           [{identificator: "tools", count: 1}],
                                max_product:  [{identificator: "tools", count: 50}]},
                              { from:         [{identificator: "boards", count: 3}, {identificator: "metal", count: 3}],
                                to:           [{identificator: "weapon", count: 1}],
                                max_product:  [{identificator: "weapon", count: 20}]}
                            ],
                plant_type_id: forge)

PlantLevel.create(level: "3", deposit: "10500", price: {"stone_brick" => 200, "metal" => 60, "tools" => 20},
                  formulas: [
                              { from:         [{identificator: "boards", count: 6}, {identificator: "metal", count: 1}],
                                to:           [{identificator: "tools", count: 1}],
                                max_product:  [{identificator: "tools", count: 120}]},
                              { from:         [{identificator: "boards", count: 3}, {identificator: "metal", count: 3}],
                                to:           [{identificator: "weapon", count: 1}],
                                max_product:  [{identificator: "weapon", count: 50}]},
                              { from:         [{identificator: "metal", count: 8}],
                                to:           [{identificator: "armor", count: 1}],
                                max_product:  [{identificator: "armor", count: 20}]}
                            ],
                  plant_type_id: forge)


Plant.create(plant_level_id: 1, plant_place_id: 1, economic_subject_id: 1, economic_subject_type: "Guild", params: {"produced" => []})


# Создание PlantPlace для регионов
# Перерабатывающие предприятия - доступны во всех регионах
Region.all.each do |region|
  PlantPlace.create(name: "Место для перерабатывающих предприятий в #{region.name}", plant_category: per, region: region)
end

# Добывающие предприятия - только в регионах с соответствующими месторождениями
# Поля пшеницы, Делянка, Каменоломня
["Великое Московское княжество", "Вологодская земля", "Нижегородская земля", "Ярославское княжество"].each do |region_name|
  region = Region.find_by(name: region_name)
  if region
    pp = PlantPlace.create(name: "Место для добывающих предприятий в #{region_name}", plant_category: dob, region: region)
    pp.fossil_types << [fertile_land_fossil, timber_fossil, stone_fossil]
  end
end

# Ферма
["Псковское княжество", "Новгородская земля", "Подвинье", "Тверское княжество"].each do |region_name|
  region = Region.find_by(name: region_name)
  if region
    pp = PlantPlace.create(name: "Место для добывающих предприятий в #{region_name}", plant_category: dob, region: region)
    pp.fossil_types << pasture_fossil
  end
end

# Драгоценный рудник
["Канинская земля", "Ненецкая земля", "Чернигово-Северское княжество"].each do |region_name|
  region = Region.find_by(name: region_name)
  if region
    pp = PlantPlace.create(name: "Место для добывающих предприятий в #{region_name}", plant_category: dob, region: region)
    pp.fossil_types << gem_ore_fossil
  end
end

# Железный рудник
["Малая Пермь", "Великая Пермь", "Вятская земля", "Рязанское княжество", "Смоленское княжество", "Верховское княжество", "Торопецкое княжество"].each do |region_name|
  region = Region.find_by(name: region_name)
  if region
    pp = PlantPlace.create(name: "Место для добывающих предприятий в #{region_name}", plant_category: dob, region: region)
    pp.fossil_types << iron_ore_fossil
  end
end


