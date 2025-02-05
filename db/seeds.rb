Human.create(name: "Михаил Соколов")
Human.create(name: "Милана Майорова")
Human.create(name: "Александр Осипов")
Human.create(name: "Фёдор Захаров")
Human.create(name: "Никита Некрасов")
Human.create(name: "Саша Никифоров")
Human.create(name: "Марьям Ковалева")
Human.create(name: "Илья Волков ")
Human.create(name: "Мирослава Чернова")
Human.create(name: "Александра Кузьмина")
Human.create(name: "Павел Самсонов")
Human.create(name: "Леон Захаров")
Human.create(name: "Вася Пупкин")
Human.create(name: "Петя Горшков")
Human.create(name: "Вова Распутин")
Human.create(name: "Анна Неболей")
Human.create(name: "Надя Петрова")
Human.create(name: "Саша Никифоров")

PlayerType.create(title: "Купец")
PlayerType.create(title: "Знать")
PlayerType.create(title: "Мудрец")
PlayerType.create(title: "Дух народного бунта")

Family.create(name: "Рюриковичи")
Family.create(name: "Аксаковы")
Family.create(name: "Патрикеевы")
Family.create(name: "Волоцкие")
Family.create(name: "Большие")
Family.create(name: "Молодые")
Family.create(name: "Голицины")

Job.create(name: "Великий князь")
Job.create(name: "Наследник престола")
Job.create(name: "Посольский дьяк")
Job.create(name: "Казначей")
Job.create(name: "Главный воевода")
Job.create(name: "Митропот Московский и всея Руси")
Job.create(name: "Первый думный боярин")
Job.create(name: "Тайный советник")
Job.create(name: "Окольничий")
Job.create(name: "Дух русского бунта")
Job.create(name: "Глава купеческого приказа")
Job.create(name: "Глава гульдии")

Player.create(name: "Иван III", human_id: 1, player_type_id: 2, job_id: 1, family_id: 1, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Борис", human_id: 2, player_type_id: 2, job_id: 2, family_id: 2, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Манюня", human_id: 3, player_type_id: 2, job_id: 3, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Распутин", human_id: 4, player_type_id: 2, job_id: 4, family_id: 4, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Геронтий", human_id: 5, player_type_id: 2, job_id: 5, family_id: 1, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Образина", human_id: 6, player_type_id: 2, job_id: 6, family_id: 5, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Распутин", human_id: 7, player_type_id: 2, job_id: 7, family_id: 6, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Хренов", human_id: 8, player_type_id: 2, job_id: 8, family_id: 7, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Даниил", human_id: 9, player_type_id: 2, job_id: 9, family_id: 1, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Марфа", human_id: 10, player_type_id: 1, family_id: 1, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Шимяка", human_id: 11, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Шелом", human_id: 12, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Яромила", human_id: 13, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Булат", human_id: 14, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Богатина", human_id: 15, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Алтын", human_id: 16, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Любава", human_id: 17, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})
Player.create(name: "Матрена", human_id: 18, player_type_id: 1, family_id: 3, params: {"influence" => 0, "contraband" => []})

current_year = 1
GameParameter.create(id: current_year, title: "Текущий год", identificator: "current_year", value: "1", params:
{"state_expenses" => false})
GameParameter.create(title: "Ставка кредита (%)", identificator: "credit_size", value: "20")
GameParameter.create(title: "Срок кредита (лет)", identificator: "credit_term", value: "3")



Guild.create(name: "Забавники")
Guild.create(name: "Каменщики")
Guild.create(name: "Пивовары")


#Русь
rus = 1
Country.create(title: "Русь", id: rus, params: {"relations" => nil, "embargo" => nil})

#Большая орда
horde = 2
Country.create(title: "Большая орда", id: horde, params: {"relations" => 0, "embargo" => false})

Resource.create(name: "Лошади", identificator: "horses", country_id: horde, params:
{"sale_price" => {-2 => 127, -1 => 109, 0 => 91,  1 => 91, 2 => 91},
"buy_price" => {-2 => 51, -1 => 58, 0 => 64, 1 => 70, 2 => 77}})

Resource.create(name: "Pоскошь", identificator: "luxury", country_id: horde, params:
{"sale_price" => {-2 => 998, -1 => 856, 0 => 713,  1 => 713, 2 => 713},
"buy_price" => {-2 => 399, -1 => 449, 0 => 499, 1 =>549, 2 => 599}})

#Ливонский орден
livonian = 3
Country.create(title: "Ливонский орден", id: livonian, params: {"relations" => 0, "embargo" => false})

Resource.create(name: "Каменный кирпич", identificator: "stone_brick", country_id: livonian, params:
  {"sale_price" => {-2 => 21, -1 => 18, 0 => 15,   1 => 15, 2 => 15},
"buy_price" => {-2 => 9, -1 => 10, 0 => 11, 1 => 12, 2 => 13}})
Resource.create(name: "Камень", identificator: "stone", country_id: livonian, params:
  {"sale_price" => {-2 => 28, -1 => 24, 0 => 20,   1 => 20, 2 => 20},
"buy_price" => {-2 => 11, -1 => 13, 0 => 14, 1 => 15, 2 => 17}})
Resource.create(name: "Доспехи", identificator: "armor", country_id: livonian, params:
  {"sale_price" => {-2 => 861, -1 => 738, 0 => 615,   1 => 615, 2 => 615},
"buy_price" => {-2 => 344, -1 => 387, 0 => 430, 1 => 473, 2 => 516}})

#Швеция
swe = 4
Country.create(title: "Швеция", id: swe, params: {"relations" => 0, "embargo" => false})

Resource.create(name: "Драгоценный металл", identificator: "gems", country_id: swe, params:
  {"sale_price" => {-2 => nil, -1 => nil, 0 => nil,  1 => nil, 2 => nil},
  "buy_price" => {-2 => 77, -1 => 86, 0 => 96, 1 => 106, 2 => 115}})
Resource.create(name: "Драгоценная руда", identificator: "gem_ore", country_id: swe, params:
  {"sale_price" => {-2 => nil, -1 => nil, 0 => nil,  1 => nil, 2 => nil},
  "buy_price" => {-2 => 11, -1 => 13, 0 => 14, 1 => 15, 2 => 17}})
Resource.create(name: "Металл", identificator: "metal", country_id: swe, params:
  {"sale_price" => {-2 => 66, -1 => 56, 0 => 47,  1 => 47, 2 => 40},
  "buy_price" => {-2 => 26, -1 => 30, 0 => 33, 1 => 36, 2 => 40}})

#Великое княжество литовское
lithuania = 5
Country.create(title: "Великое княжество литовское", id: lithuania, params: {"relations" => 0, "embargo" => false})

Resource.create(name: "Инструменты", identificator: "tools", country_id: lithuania, params:
  {"sale_price" => {-2 => 186, -1 => 160, 0 => 133,  1 => 133, 2 => 133},
  "buy_price" => {-2 => 74, -1 => 84, 0 => 93, 1 => 102, 2 => 112}})
Resource.create(name: "Бревна", identificator: "timber", country_id: lithuania, params:
  {"sale_price" => {-2 => 14, -1 => 12, 0 => 10,   1 => 10, 2 => 10},
  "buy_price" => {-2 => 6, -1 => 6, 0 => 7, 1 => 8, 2 => 8}})
Resource.create(name: "Доски", identificator: "boards", country_id: lithuania, params:
  {"sale_price" => {-2 => 13, -1 => 11, 0 => 9,   1 => 9, 2 => 9},
  "buy_price" => {-2 => 6, -1 => 11, 0 => 9, 1 => 9, 2 => 9}})

#Казанское ханство
kazan = 6
Country.create(title: "Казанское ханство", id: kazan, params: {"relations" => 0, "embargo" => false})

Resource.create(name: "Железная руда", identificator: "metal_ore", country_id: kazan, params:
  {"sale_price" => {-2 => 10, -1 => 8, 0 => 7,   1 => 7, 2 => 7},
  "buy_price" => {-2 => 4, -1 => 5, 0 => 5, 1 => 6, 2 => 6}})
Resource.create(name: "Mясо", identificator: "meat", country_id: kazan, params:
  {"sale_price" => {-2 => 27, -1 => 23, 0 => 19,   1 => 19, 2 => 19},
 "buy_price" => {-2 => 10, -1 => 12, 0 => 13, 1 => 14, 2 => 16}})
Resource.create(name: "Провизия", identificator: "food", country_id: kazan, params:
  {"sale_price" => {-2 => 136, -1 => 116, 0 => 97,   1 => 2, 2 => 97},
  "buy_price" => {-2 => 54, -1 => 61, 0 => 68, 1 => 75, 2 => 82}})

#Крымское ханство
crimea = 7
Country.create(title: "Крымское ханство", id: crimea, params: {"relations" => 0, "embargo" => false})

Resource.create(name: "Зерно", identificator: "grain", country_id: crimea, params:
  {"sale_price" => {-2 => 4, -1 => 3, 0 => 3,  1 => 3, 2 => 3},
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



cap = SettlementType.create(name: "Столица", params: {"income" => 10000})
town = SettlementType.create(name: "Город", params: {"income" => 5000})
for_cap = SettlementType.create(name: "Иностранный город", params: {"income" => 0})
for_town = SettlementType.create(name: "Иностранная столица", params: {"income" => 10000})


Region.create(title: "Московское княжество", country_id: 1, params: {"public_order" => 0})
Region.create(title: "Ярославское княжество", country_id: 1, params: {"public_order" => 0})

Settlement.create(name: "Або", settlement_type_id: cap.id, region_id: 1, player_id: 1, params: {"open_gate" => false})
Settlement.create(name: "Азак", settlement_type_id: cap.id, region_id: 1, player_id: 2, params: {"open_gate" => false})
Settlement.create(name: "Алексин", settlement_type_id: cap.id, region_id: 1, player_id: 3, params: {"open_gate" => false})
Settlement.create(name: "Арзамас", settlement_type_id: cap.id, region_id: 1, player_id: 4, params: {"open_gate" => false})
Settlement.create(name: "Бахчисарай", settlement_type_id: cap.id, region_id: 1, player_id: 5, params: {"open_gate" => false})
Settlement.create(name: "Белоозеро", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Биляр", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Брацлав", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Брянск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Булгар", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Варзуга", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Великий Новгород", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Великий Устюг", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Вильно", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Виндава", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Вологда", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Волок Ламский", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Выборг", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Дерпт", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Джулат", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Елец", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Житомир", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Ислам-Керман", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Казань", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Канев", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Каргополь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Кемь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Киев", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Кичмента", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Койгородок", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Коломна", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Кострома", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Котельнич", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Ладога", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Маджар", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Минск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Можайск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Москва", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Мохши", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Мстиславль", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Муром", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Нижний Новгород", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Новгород-Северский", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Нюслотт", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Нюхча", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Одоев", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Орлец", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Орша", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Переславль-Рязанский", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Пермь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Псков", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Ревель", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Рига", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Руза", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Рыльск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Самар", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Сарай бату", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Сарай-Бекке", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Сарайчик", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Смолненск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Стародуб", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Суздаль", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Тверь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Торопец", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Тула", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Туров", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Увек", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Углич", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Умба", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Усогорск", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Усть-Вымь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Усть-Цильма", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Фарах-Керман", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Хаджитархан", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Хлынов", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Холмогоры", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Чаллы", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Чердынь", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Чернигов", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Чимги-тура", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})
Settlement.create(name: "Ярославль", settlement_type_id: cap.id, region_id: 1, player_id: 6, params: {"open_gate" => false})

dob = PlantCategory.create(name: "Добывающее")
per = PlantCategory.create(name: "Перерабатывающее")

delyan = 1
PlantType.create(id: delyan, name: "Делянка", plant_category: dob)

farm = 2
PlantType.create(id: farm, name: "Ферма", plant_category: dob)

field = 3
PlantType.create(id: field, name: "Поле пшеницы", plant_category: dob)

quarry = 4
PlantType.create(id: quarry, name: "Каменоломня", plant_category: dob)


iron_mine = 5
PlantType.create(id: iron_mine, name: "Железный рудник", plant_category: dob)


gold_mine = 6
PlantType.create(id: gold_mine, name: "Драгоценный рудник", plant_category: dob)





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

PlantLevel.create(level: "3", deposit: "4100", price: {"timber" => 75, "grain" => 225, "tools" => 30},
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

PlantLevel.create(level: "2", deposit: "1900", price: {"grain" => 225, "stone" => 20},
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

PlantLevel.create(level: "3", deposit: "3400", price: {"stone" => 45, "timber" => 50, "food" => 15},
                  formulas: [{from:         [],
                            to:           [{identificator: "stone", count: 300}],
                            max_product:  [{identificator: "stone", count: 300}]}],
                  plant_type_id: quarry)



PlantLevel.create(level: "1", deposit: "1800", price: {"stone_brick" => 200, "timber" => 75},
                  formulas: [{from:         [],
                            to:           [{identificator: "metal_ore", count: 200}],
                            max_product:  [{identificator: "metal_ore", count: 200}]}],
                  plant_type_id: iron_mine)

PlantLevel.create(level: "2", deposit: "3000", price: {"stone_brick" => 75, "timber" => 75},
                  formulas: [{from:         [],
                            to:           [{identificator: "metal_ore", count: 400}],
                            max_product:  [{identificator: "metal_ore", count: 400}]}],
                  plant_type_id: iron_mine)

PlantLevel.create(level: "3", deposit: "5200", price: {"stone_brick" => 120, "timber" => 50, "food" => 20},
                  formulas: [{from:         [],
                            to:           [{identificator: "metal_ore", count: 1000}],
                            max_product:  [{identificator: "metal_ore", count: 1000}]}],
                  plant_type_id: iron_mine)


PlantLevel.create(level: "1", deposit: "2000", price: {"stone" => 75, "boards" => 200},
                  formulas: [{from:         [],
                            to:           [{identificator: "gem_ore", count: 200}],
                            max_product:  [{identificator: "gem_ore", count: 200}]}],
                  plant_type_id: gold_mine)

PlantLevel.create(level: "2", deposit: "3400", price: {"stone" => 40, "boards" => 150},
                  formulas: [{from:         [],
                            to:           [{identificator: "gem_ore", count: 400}],
                            max_product:  [{identificator: "gem_ore", count: 400}]}],
                  plant_type_id: gold_mine)

PlantLevel.create(level: "3", deposit: "5500", price: {"stone" => 60, "boards" => 75, "metal" => 50},
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


PlantLevel.create(level: "2", deposit: "2200", price: {"flour" => 100, "metal" => 40},
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

PlantLevel.create(level: "2", deposit: "4500", price: {"stone_brick" => 50, "metal" => 15, "tools" => 10},
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

Settlement.create(name: "Москва", settlement_type_id: cap.id, region_id: 1, player_id: 1)
Settlement.create(name: "Тверь", settlement_type_id: cap.id, region_id: 1, player_id: 2)
Settlement.create(name: "Рязань", settlement_type_id: cap.id, region_id: 1, player_id: 3)


Settlement.create(name: "Хатавки", settlement_type_id: 2, region_id: 1, player_id: 4)
Settlement.create(name: "Гадюкино", settlement_type_id: 2, region_id: 1, player_id: 5)
Settlement.create(name: "Холмищи", settlement_type_id: 2, region_id: 1, player_id: 6)

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

BuildingType.create(title: "Религиозная постройка")
BuildingType.create(title: "Оборонительная постройка")
BuildingType.create(title: "Торговая постройка")
BuildingType.create(title: "Размер гарнизона")

BuildingLevel.create(level: 1, building_type_id: 1, name: "Часовня", params: {"public_order" => 1})
BuildingLevel.create(level: 2, building_type_id: 1, name: "Храм", params: {"public_order" => 3})
BuildingLevel.create(level: 3, building_type_id: 1, name: "Монастырь", params: {"public_order" => 5})

BuildingLevel.create(level: 1, building_type_id: 2, name: "Форт")
BuildingLevel.create(level: 2, building_type_id: 2, name: "Крепость")
BuildingLevel.create(level: 3, building_type_id: 2, name: "Кремль")

BuildingLevel.create(level: 1, building_type_id: 3, name: "Базар", params: {"income" => 1000})
BuildingLevel.create(level: 2, building_type_id: 3, name: "Рынок", params: {"income" => 2000})
BuildingLevel.create(level: 3, building_type_id: 3, name: "Ярмарка", params: {"income" => 4000})

BuildingLevel.create(level: 1, building_type_id: 4, name: "Караул")
BuildingLevel.create(level: 2, building_type_id: 4, name: "Гарнизон")
BuildingLevel.create(level: 3, building_type_id: 4, name: "Казармы")

Building.create(building_level_id: 1, settlement_id: 1, params: {"paid" => []})
Building.create(building_level_id: 2, settlement_id: 2, params: {"paid" => []})
Building.create(building_level_id: 3, settlement_id: 3, params: {"paid" => []})



Building.create(building_level_id: 4, settlement_id: 2)
Building.create(building_level_id: 5, settlement_id: 1)
Building.create(building_level_id: 6, settlement_id: 2)

Building.create(building_level_id: 7, settlement_id: 1)


TroopType.create(title: "Арбалетчики") #CROSSBOWMEN = 1
TroopType.create(title: "Легкая кавалерия") #LIGHT_CAVALRY = 2
TroopType.create(title: "Тяжелая кавалерия")#HEAVY_CAVALRY = 3
TroopType.create(title: "Легкая пехота")  #LIGHT_INFANTRY = 4
TroopType.create(title: "Лучники") # ARCHERS = 5
TroopType.create(title: "Ополчение") #MILITIA_MEN = 6
TroopType.create(title: "Пешие рыцари") #FOOT_KIGHTS = 7
TroopType.create(title: "Пушки") #CANONS = 8
TroopType.create(title: "Рыцари") #KNIGHTS = 9
TroopType.create(title: "Степные лучники") #STEPPE_ARCHERS = 10
TroopType.create(title: "Стрельцы") #STRELTSY = 11
TroopType.create(title: "Таран") #BATTERING_RAM = 12

Troop.create(troop_type_id: 2, is_hired: true, army: army1)
Troop.create(troop_type_id: 3, is_hired: true, army: army1)
Troop.create(troop_type_id: 4, is_hired: true, army: army1)

# Plant.create(name: "Мастерская каменотёса", economic_subject_id: 2,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Трактир", economic_subject_id: 3,economic_subject_type: "Player", plant_category_id: 2, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Player", plant_category_id: 2, level: 1)
# Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild", plant_category_id: 2, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 1,economic_subject_type: "Player", plant_category_id: 1, level: 1)
# Plant.create(name: "Каменоломня", economic_subject_id: 2,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 1,economic_subject_type: "Player", plant_category_id: 1, level: 1)
# Plant.create(name: "Рудник", economic_subject_id: 4,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Золотой рудник", economic_subject_id: 5,economic_subject_type: "Player", plant_category_id: 1, level: 1)
# Plant.create(name: "Делянка", economic_subject_id: 6,economic_subject_type: "Guild", plant_category_id: 1, level: 1)
# Plant.create(name: "Делянка", economic_subject_type: "Guild", plant_category_id: 1, level: 1)

Troop.create(troop_type_id: 7, is_hired: true, army: army2)
Troop.create(troop_type_id: 4, is_hired: true, army: army2)
Troop.create(troop_type_id: 6, is_hired: true, army: army2)

PoliticalActionType.create(title: "Подстрекательство к бунту", action: 'sedition')
PoliticalActionType.create(title: "Благотворительность", action: "charity")
PoliticalActionType.create(title: "Шпионаж", action: 'espionage')
PoliticalActionType.create(title: "Саботаж", action: 'sabotage')
PoliticalActionType.create(title: "Контрабанда", action: 'contraband')
PoliticalActionType.create(title: "Открыть ворота!", action: 'open_gate')
PoliticalActionType.create(title: "Новые промыслы", action: 'new_fisheries')
PoliticalActionType.create(title: "Отправить посольство", action: 'send_embassy')
PoliticalActionType.create(title: "Снарядить караван", action: 'equip_caravan')
PoliticalActionType.create(title: "Взять мзду", action: 'take_bribe')
PoliticalActionType.create(title: "Провести ревизию", action: 'сonduct_audit')
PoliticalActionType.create(title: "Казнокрадство", action: 'peculation')
PoliticalActionType.create(title: "Разогнать мздоимцев", action: 'disperse_bribery')
PoliticalActionType.create(title: "Осуществить саботаж", action: 'implement_sabotage')
PoliticalActionType.create(title: "Именем Великого князя", action: 'name_of_grand_prince')
PoliticalActionType.create(title: "Набрать рекрутов", action: 'recruiting')

