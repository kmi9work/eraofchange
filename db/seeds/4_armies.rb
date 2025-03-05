small = 1
ArmySize.create(id: small, name: "Малая",   level: 1, params:  {renewal_cost: {"gold" => 7000},  buy_cost: {"arms" => 4, "rations" => 5, "armour" => 1, "horses" => 3, "max_troops" => 4}})
medium = 2
ArmySize.create(id: medium, name: "Средняя", level: 2, params:  {renewal_cost: {"gold" => 12000}, buy_cost: {"arms" => 8, "rations" => 10, "armour" => 2, "horses" => 6, "max_troops" => 8}})
large = 3
ArmySize.create(id: large, name: "Большая", level: 3, params:  {renewal_cost: {"gold" => 16000}, buy_cost: {"arms" => 12, "rations" => 15, "armour" => 4, "horses" => 10, "max_troops" => 12}})
army1 = Army.create(region_id: 1, player_id: 1, army_size_id: 1, params: {"paid" =>[], "palsy" => []})
army2 = Army.create(region_id: 1, player_id: 2, army_size_id: 1, params: {"paid" =>[], "palsy" => []})
army3 = Army.create(region_id: 1, player_id: 3, army_size_id: 2, params: {"paid" =>[], "palsy" => []})
army4 = Army.create(region_id: 1, player_id: 4, army_size_id: 2, params: {"paid" =>[], "palsy" => []})
army5 = Army.create(region_id: 1, player_id: 5, army_size_id: 3, params: {"paid" =>[], "palsy" => []})
army6 = Army.create(region_id: 1, player_id: 6, army_size_id: 3, params: {"paid" =>[], "palsy" => [2, 3]})

TroopType.create(name: "Арбалетчики") #CROSSBOWMEN = 1
TroopType.create(name: "Легкая кавалерия") #LIGHT_CAVALRY = 2
TroopType.create(name: "Тяжелая кавалерия")#HEAVY_CAVALRY = 3
TroopType.create(name: "Легкая пехота")  #LIGHT_INFANTRY = 4
TroopType.create(name: "Лучники") # ARCHERS = 5
TroopType.create(name: "Ополчение") #MILITIA_MEN = 6
TroopType.create(name: "Пешие рыцари") #FOOT_KIGHTS = 7
TroopType.create(name: "Пушки") #CANONS = 8
TroopType.create(name: "Рыцари") #KNIGHTS = 9
TroopType.create(name: "Степные лучники") #STEPPE_ARCHERS = 10
TroopType.create(name: "Стрельцы") #STRELTSY = 11
TroopType.create(name: "Таран") #BATTERING_RAM = 12

Troop.create(troop_type_id: 2, is_hired: true, army: army1)
Troop.create(troop_type_id: 3, is_hired: true, army: army1)
Troop.create(troop_type_id: 4, is_hired: true, army: army1)

Troop.create(troop_type_id: 7, is_hired: true, army: army2)
Troop.create(troop_type_id: 4, is_hired: true, army: army2)
Troop.create(troop_type_id: 6, is_hired: true, army: army2)