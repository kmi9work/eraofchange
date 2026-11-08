# Стоимость отряда — ТОЛЬКО полная цена постройки с нуля: отряды больше не
# улучшаются (цепочка «пехота → тяжёлая пехота → кавалерия → пушка» из
# TroopType.upgrade_paths в найме не используется). Поэтому в buy_cost каждого
# типа лежит ровно его собственная цена, без удешевления «доплатить за апгрейд».
TroopType.create(name: "Пехота", params: {
  'power' => 1, 
  'max_health' => 1,
  'buy_cost' => [
    {"identificator" => "meat", "count" => 50}
  ]
}) #MILITIA = 1
TroopType.create(name: "Тяжелая пехота", params: {
  'power' => 3,
  'max_health' => 3,
  'buy_cost' => [
    {"identificator" => "metal", "count" => 20},
    {"identificator" => "meat", "count" => 70}
  ]
}) #HEAVY_MILITIA = 2
TroopType.create(name: "Кавалерия", params: {
  'power' => 5,
  'max_health' => 5,
  'buy_cost' => [
    {"identificator" => "weapon", "count" => 5},
    {"identificator" => "horses", "count" => 30}
  ]
}) #CAVALRY = 3

TroopType.create(name: "Пушка", params: {
  'power' => 8,
  'max_health' => 8,
  'buy_cost' => [
    {"identificator" => "tools", "count" => 30}
  ]
}) #CANNON = 4

# Город под армией берём по имени из `countries.csv`. Если карта изменилась и
# города больше нет — сид падает с понятным сообщением, а не создаёт армию без
# места: такая армия рисуется клиентом у столицы как «не размещённая на карте»
# (docs/map/TZ-karta.md, § 14.3), то есть молча стоит не там, где задумано.
army_city = lambda do |name|
  city = Settlement.find_by_name(name)
  if city.nil?
    raise "4_armies.rb: город «#{name}» не найден. Карта изменилась — обновите " \
          "db/seeds/countries.csv и имена городов в этом сиде (docs/map/TZ-karta.md)."
  end
  city
end

army1 = Army.create(name: 'Рюрикович', settlement: army_city.call('Москва'), owner: Player.find_by_name('Рюрикович'), owner_type: 'Player', hidden: false, params: { "palsy" => []})
army2 = Army.create(name: 'Молодой', settlement: army_city.call('Муром'), owner: Player.find_by_name('Молодой'), owner_type: 'Player', hidden: false, params: { "palsy" => []})
army3 = Army.create(name: 'Волоцкий', settlement: army_city.call('Вологда'), owner: Player.find_by_name('Волоцкий'), owner_type: 'Player', hidden: false, params: {"palsy" => []})


Troop.create(troop_type_id: 3, is_hired: false, army: army1, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: army2, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: army3, params: {"paid" =>[], 'damage' => 0})


a = Army.create(name: 'Казань', settlement: army_city.call('Казань'), owner: Country.find_by_name('Казанское ханство'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Крым', settlement: army_city.call('Бахчисарай'), owner: Country.find_by_name('Крымское ханство'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Литва 1', settlement: army_city.call('Смоленск'), owner: Country.find_by_name('Великое княжество Литовское'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Литва 2', settlement: army_city.call('Минск'), owner: Country.find_by_name('Великое княжество Литовское'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Ливония', settlement: army_city.call('Рига'), owner: Country.find_by_name('Ливонский орден'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 4, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Швеция', settlement: army_city.call('Выборг'), owner: Country.find_by_name('Королевство Швеция'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Тверь', settlement: army_city.call('Тверь'), owner: Country.find_by_name('Тверь'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Новгород 1', settlement: army_city.call('Псков'), owner: Country.find_by_name('Великий Новгород'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 1, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Новгород 2', settlement: army_city.call('Великий Новгород'), owner: Country.find_by_name('Великий Новгород'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Пермь', settlement: army_city.call('Пермь'), owner: Country.find_by_name('Пермь'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 1, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Рязань', settlement: army_city.call('Переславль-Рязанский'), owner: Country.find_by_name('Рязань'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Вятка', settlement: army_city.call('Хлынов'), owner: Country.find_by_name('Вятка'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

# На новой карте (05.11.2026) городов Мохши и Увек нет: армии Орды
# стоят в сохранившихся городах — Самар (север Орды) и Сарай (столица).
a = Army.create(name: 'Орда 1', settlement: army_city.call('Самар'), owner: Country.find_by_name('Большая Орда'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 3, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

a = Army.create(name: 'Орда 2', settlement: army_city.call('Сарай'), owner: Country.find_by_name('Большая Орда'), owner_type: 'Country', hidden: true, params: {"paid" =>[], "palsy" => []})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})
Troop.create(troop_type_id: 2, is_hired: false, army: a, params: {"paid" =>[], 'damage' => 0})

