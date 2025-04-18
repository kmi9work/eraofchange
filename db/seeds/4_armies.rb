army1 = Army.create(settlement_id: 1, owner_id: 1, owner_type: 'Player', params: { "palsy" => []})
army2 = Army.create(settlement_id: 1, owner_id: 2, owner_type: 'Player', params: { "palsy" => []})
army3 = Army.create(settlement_id: 1, owner_id: 3, owner_type: 'Player', params: {"palsy" => []})
army4 = Army.create(settlement_id: 1, owner_id: 4, owner_type: 'Player', params: {"paid" =>[], "palsy" => []})
army5 = Army.create(settlement_id: 1, owner_id: 2, owner_type: 'Country', params: {"paid" =>[], "palsy" => []})
army6 = Army.create(settlement_id: 1, owner_id: 3, owner_type: 'Country', params: {"paid" =>[], "palsy" => [2, 3]})

TroopType.create(name: "Пехота", params: {
  'power' => 1, 
  'max_health' => 1,
  'buy_cost' => [
    {identificator: "money", count: 500},
    {identificator: "food", count: 5}, 
    {identificator: "weapon", count: 5}
  ]
}) #MILITIA = 1
TroopType.create(name: "Тяжелая пехота", params: {
  'power' => 3,
  'max_health' => 3,
  'buy_cost' => [
    {identificator: "money", count: 1000},
    {identificator: "food", count: 10}, 
    {identificator: "weapon", count: 0},
    {identificator: "armor", count: 5}
  ]
}) #HEAVY_MILITIA = 2
TroopType.create(name: "Кавалерия", params: {
  'power' => 5,
  'max_health' => 5,
  'buy_cost' => [
    {identificator: "money", count: 2000},
    {identificator: "food", count: 30}, 
    {identificator: "weapon", count: 0},
    {identificator: "armor", count: 0},
    {identificator: "horses", count: 30}
  ]
}) #CAVALRY = 3

TroopType.create(name: "Пушка", params: {
  'power' => 8,
  'max_health' => 8,
  'buy_cost' => [
    {identificator: "money", count: 1000},
    {identificator: "food", count: 0}, 
    {identificator: "weapon", count: 0},
    {identificator: "armor", count: 0},
    {identificator: "horses", count: 0},
    {identificator: "tools", count: 20}, 
    {identificator: "metal", count: 20}
  ]
}) #CAVALRY = 3

Troop.create(troop_type_id: 1, is_hired: true, army: army1, params: {"paid" =>[1], 'canon' => false, 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: true, army: army1, params: {"paid" =>[1], 'canon' => false, 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: true, army: army1, params: {"paid" =>[],  'canon' => false, 'damage' => 0})

Troop.create(troop_type_id: 2, is_hired: true, army: army2, params: {"paid" =>[], 'canon' => false, 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: true, army: army2, params: {"paid" =>[], 'canon' => true, 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: true, army: army2, params: {"paid" =>[],  'canon' => true, 'damage' => 0})