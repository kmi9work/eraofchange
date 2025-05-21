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
}) #CANNON = 4

army1 = Army.create(name: 'Рюрикович', settlement: Settlement.find_by_name('Москва'), owner: Player.find_by_name('Рюрикович'), owner_type: 'Player', hidden: false, params: { "palsy" => []})
army2 = Army.create(name: 'Молодой', settlement: Settlement.find_by_name('Муром'), owner: Player.find_by_name('Молодой'), owner_type: 'Player', hidden: false, params: { "palsy" => []})
army3 = Army.create(name: 'Волоцкий', settlement: Settlement.find_by_name('Вологда'), owner: Player.find_by_name('Волоцкий'), owner_type: 'Player', hidden: false, params: {"palsy" => []})


Troop.create(troop_type_id: 3, is_hired: false, army: army1, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: army2, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: army3, params: {"paid" =>[], 'damage' => 0})


a = Army.create(name: 'Казань', settlement: Settlement.find_by_name('Казань'), owner: Country.find_by_name('Казанское ханство'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Крым', settlement: Settlement.find_by_name('Бахчисарай'), owner: Country.find_by_name('Крымское ханство'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Литва 1', settlement: Settlement.find_by_name('Смоленск'), owner: Country.find_by_name('Великое княжество Литовское'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Литва 2', settlement: Settlement.find_by_name('Минск'), owner: Country.find_by_name('Великое княжество Литовское'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Ливония', settlement: Settlement.find_by_name('Рига'), owner: Country.find_by_name('Ливонский орден'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 4, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Швеция', settlement: Settlement.find_by_name('Выборг'), owner: Country.find_by_name('Королевство Швеция'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Тверь', settlement: Settlement.find_by_name('Тверь'), owner: Country.find_by_name('Тверь'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Новгород 1', settlement: Settlement.find_by_name('Псков'), owner: Country.find_by_name('Великий Новгород'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 1, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Новгород 2', settlement: Settlement.find_by_name('Великий Новгород'), owner: Country.find_by_name('Великий Новгород'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Пермь', settlement: Settlement.find_by_name('Пермь'), owner: Country.find_by_name('Пермь'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 1, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Рязань', settlement: Settlement.find_by_name('Переславль-Рязанский'), owner: Country.find_by_name('Рязань'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Вятка', settlement: Settlement.find_by_name('Хлынов'), owner: Country.find_by_name('Вятка'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Орда 1', settlement: Settlement.find_by_name('Мохши'), owner: Country.find_by_name('Большая Орда'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Орда 2', settlement: Settlement.find_by_name('Увек'), owner: Country.find_by_name('Большая Орда'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

