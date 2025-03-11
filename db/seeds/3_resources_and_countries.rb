#Русь
rus = Country.find_by_name("Русь").id

#Большая орда

horde = Country.find_by_name("Большая Орда").id

Resource.create(name: "Лошади", identificator: "horses", country_id: horde, params:
{"sale_price" => {-2 => 127, -1 => 109, 0 => 91,  1 => 91, 2 => 91},
"buy_price" => {-2 => 51, -1 => 58, 0 => 64, 1 => 70, 2 => 77}})

Resource.create(name: "Pоскошь", identificator: "luxury", country_id: horde, params:
{"sale_price" => {-2 => 1000, -1 => 860, 0 => 700,  1 => 700, 2 => 700},
"buy_price" => {-2 => 400, -1 => 450, 0 => 500, 1 =>550, 2 => 600}})

#Ливонский орден
livonian = Country.find_by_name("Ливонский орден").id

Resource.create(name: "Каменный кирпич", identificator: "stone_brick", country_id: livonian, params:
  {"sale_price" => {-2 => 21, -1 => 18, 0 => 15,   1 => 15, 2 => 15},
"buy_price" => {-2 => 9, -1 => 10, 0 => 11, 1 => 12, 2 => 13}})
Resource.create(name: "Камень", identificator: "stone", country_id: livonian, params:
  {"sale_price" => {-2 => 28, -1 => 24, 0 => 20,   1 => 20, 2 => 20},
"buy_price" => {-2 => 11, -1 => 13, 0 => 14, 1 => 15, 2 => 17}})
Resource.create(name: "Доспехи", identificator: "armor", country_id: livonian, params:
  {"sale_price" => {-2 => 860, -1 => 740, 0 => 615,   1 => 615, 2 => 615},
"buy_price" => {-2 => 350, -1 => 390, 0 => 430, 1 => 475, 2 => 520}})

#Швеция
swe = Country.find_by_name("Королевство Швеция").id

Resource.create(name: "Драгоценный металл", identificator: "gems", country_id: swe, params:
  {"sale_price" => {-2 => nil, -1 => nil, 0 => nil,  1 => nil, 2 => nil},
  "buy_price" => {-2 => 77, -1 => 86, 0 => 96, 1 => 106, 2 => 115}})
Resource.create(name: "Драгоценная руда", identificator: "gem_ore", country_id: swe, params:
  {"sale_price" => {-2 => nil, -1 => nil, 0 => nil,  1 => nil, 2 => nil},
  "buy_price" => {-2 => 11, -1 => 13, 0 => 14, 1 => 15, 2 => 17}})

Resource.create(name: "Металл", identificator: "metal", country_id: swe, params:
  {"sale_price" => {-2 => 66, -1 => 56, 0 => 47,  1 => 47, 2 => 47},
  "buy_price" => {-2 => 26, -1 => 30, 0 => 33, 1 => 36, 2 => 40}})

#Великое княжество Литовское
lithuania = Country.find_by_name("Великое княжество Литовское").id

Resource.create(name: "Инструменты", identificator: "tools", country_id: lithuania, params:
  {"sale_price" => {-2 => 186, -1 => 160, 0 => 133,  1 => 133, 2 => 133},
  "buy_price" => {-2 => 74, -1 => 84, 0 => 93, 1 => 102, 2 => 112}})
Resource.create(name: "Бревна", identificator: "timber", country_id: lithuania, params:
  {"sale_price" => {-2 => 14, -1 => 12, 0 => 10,   1 => 10, 2 => 10},
  "buy_price" => {-2 => 6, -1 => 6, 0 => 7, 1 => 8, 2 => 8}})
Resource.create(name: "Доски", identificator: "boards", country_id: lithuania, params:
  {"sale_price" => {-2 => 13, -1 => 11, 0 => 9,   1 => 9, 2 => 9},
  "buy_price" => {-2 => 6, -1 => 6, 0 => 7, 1 => 8, 2 => 8}})

#Казанское ханство
kazan = Country.find_by_name("Казанское ханство").id

Resource.create(name: "Железная руда", identificator: "metal_ore", country_id: kazan, params:
  {"sale_price" => {-2 => 10, -1 => 8, 0 => 7,   1 => 7, 2 => 7},
  "buy_price" => {-2 => 4, -1 => 5, 0 => 5, 1 => 6, 2 => 6}})
Resource.create(name: "Mясо", identificator: "meat", country_id: kazan, params:
  {"sale_price" => {-2 => 27, -1 => 23, 0 => 19,   1 => 19, 2 => 19},
 "buy_price" => {-2 => 10, -1 => 12, 0 => 13, 1 => 14, 2 => 16}})
Resource.create(name: "Провизия", identificator: "food", country_id: kazan, params:
  {"sale_price" => {-2 => 136, -1 => 116, 0 => 97,   1 => 97, 2 => 97},
  "buy_price" => {-2 => 54, -1 => 61, 0 => 68, 1 => 75, 2 => 82}})

#Крымское ханство
crimea = Country.find_by_name("Крымское ханство").id

Resource.create(name: "Зерно", identificator: "grain", country_id: crimea, params:
  {"sale_price" => {-2 => 4, -1 => 4, 0 => 3,  1 => 3, 2 => 3},
   "buy_price" => {-2 => 2, -1 => 2, 0 => 2, 1 => 2, 2 => 2}})
Resource.create(name: "Mука", identificator: "flour", country_id: crimea, params:
  {"sale_price" => {-2 => 21, -1 => 18, 0 => 15,   1 => 15, 2 => 15},
  "buy_price" => {-2 => 8, -1 => 9, 0 => 10, 1 => 11, 2 => 12}})
Resource.create(name: "Оружие", identificator: "weapon", country_id: crimea, params:
  {"sale_price" => {-2 => 286, -1 => 245, 0 => 204,  1 => 204, 2 => 204},
  "buy_price" => {-2 => 114, -1 => 129, 0 => 143, 1 => 157, 2 => 172}})




#!!! Проверить параметры для золота
Resource.create(name: "Золото", identificator: "gold", country_id: nil, params:
  {"sale_price" => {-2 => 0, -1 => 0, 0 => 0,   1 => 2, 2 => 0},
  "buy_price" => {-2 => 0, -1 => 61, 0 => 0, 1 => 0, 2 => 0}})
