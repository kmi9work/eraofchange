Guild.destroy_all
PlantType.destroy_all
PlantLevel.destroy_all
Plant.destroy_all
PlantPlace.destroy_all
Resource.destroy_all
# В Artel fossil_type не используется — предприятия гильдии без привязки к месторождениям

# Статус разведданных (000..111) для экрана Артели
intelligence_status = GameParameter.find_or_initialize_by(identificator: "artel_intelligence_status")
intelligence_status.name = "Статус разведданных Артели"
intelligence_status.value = "1"
intelligence_status.params = {
  "military_recruitment" => false,
  "scientists_recruitment" => false,
  "teaching_staff_recruitment" => false
}
intelligence_status.save!

# Ресурсы Артели (для формул предприятий из artel.xlsx). country_id: nil — без привязки к стране.
# Цены только для уровня отношений 0 (в игре нет отношений).
# Покупка = цена, по которой рынок продаёт игроку (sale_price). Продажа = цена, по которой рынок покупает у игрока (buy_price).
artel_resources = [
  ["Изоляция", "izolyaciya"], ["Каучук", "kauchuk"], ["Металл", "metall"], ["Полимеры", "polimery"],
  ["Реагенты", "reagenty"], ["Ткань", "tkan"], ["Одежда", "odezhda"], ["Электронные компоненты", "el_komp"],
  ["Фарм. препараты", "farm_prep"], ["Пластины", "plastiny"], ["Резино-технические изделия", "rez_teh_izd"],
  ["Пластмассовые изделия", "plast_izd"], ["Кадры", "kadry"], ["Стимуляторы", "stimulyatory"],
  ["Бронежилеты", "bronzhevety"], ["Устройства слежения", "ust_slezh"]
]
# sale_price[0] = игрок покупает с рынка; buy_price[0] = игрок продаёт на рынок. nil = операция недоступна.
artel_prices = {
  "tkan" => { sale: 16, buy: 7 }, "metall" => { sale: 40, buy: 17 }, "polimery" => { sale: 8, buy: 3 },
  "reagenty" => { sale: 6, buy: 3 }, "kauchuk" => { sale: 16, buy: 7 }, "izolyaciya" => { sale: 24, buy: 10 },
  "odezhda" => { sale: 80, buy: 32 }, "el_komp" => { sale: 33, buy: 13 }, "farm_prep" => { sale: 90, buy: 36 },
  "plastiny" => { sale: 380, buy: 180 }, "rez_teh_izd" => { sale: 360, buy: 160 },
  "plast_izd" => { sale: 160, buy: 90 }, "kadry" => { sale: 500, buy: nil },
  "stimulyatory" => { sale: nil, buy: 1000 }, "bronzhevety" => { sale: nil, buy: 1000 }, "ust_slezh" => { sale: nil, buy: 1000 }
}
artel_resources.each do |name, ident|
  prices = artel_prices[ident] || { sale: 0, buy: 0 }
  params = {
    "sale_price" => { 0 => prices[:sale] },
    "buy_price" => { 0 => prices[:buy] }
  }
  res = Resource.find_or_create_by!(identificator: ident) { |r| r.name = name; r.country_id = nil; r.params = params }
  res.update!(name: name, country_id: nil, params: params) if res.country_id.nil?
end

guild_names = ["А", "Б", "В", "Г", "Д", "Е"]

guild_names.each {|name| Guild.create(name: name, params: {caravan_protected: []})} 
  


# Категории с иконками (Remix Icon), если есть колонка icon
cat_attrs = ->(name, icon) { PlantCategory.column_names.include?("icon") ? { name: name, icon: icon } : { name: name } }
cont = PlantCategory.create(cat_attrs.call("Контракт", "ri-file-list-3-line").merge(is_extractive: true))
per = PlantCategory.create(cat_attrs.call("Предприятие", "ri-building-line").merge(is_extractive: false))
univer = PlantCategory.create(cat_attrs.call("Университет", "ri-graduation-cap-line").merge(is_extractive: true))

# Контракты (ровно 6): Изоляция, Каучук, Металл, Полимеры, Реагенты, Ткань
pt_attrs = ->(name, cat, icon) { { name: name, plant_category: cat }.merge(PlantType.column_names.include?("icon") ? { icon: icon } : {}) }
izolyaciya = PlantType.create(pt_attrs["Изоляция", cont, "ri-shield-line"])
kauchuk = PlantType.create(pt_attrs["Каучук", cont, "ri-circle-line"])
metall = PlantType.create(pt_attrs["Металл", cont, "ri-tools-line"])
polimery = PlantType.create(pt_attrs["Полимеры", cont, "ri-flask-line"])
reagenty = PlantType.create(pt_attrs["Реагенты", cont, "ri-flask-line"])
tkan = PlantType.create(pt_attrs["Ткань", cont, "ri-t-shirt-line"])



# Контракты: 4 уровня у каждого. Уровень 1 — по таблице, далее +25% за уровень (линейно). deposit=0, цена уровня = 1 кадр.
# Изоляция: 60 → 75 → 90 → 105
[[izolyaciya, "izolyaciya", [60, 75, 90, 105]],
 [kauchuk,    "kauchuk",    [100, 125, 150, 175]],
 [metall,     "metall",     [40, 50, 60, 70]],
 [polimery,   "polimery",   [200, 250, 300, 350]],
 [reagenty,   "reagenty",   [200, 250, 300, 350]],
 [tkan,       "tkan",       [100, 125, 150, 175]]].each do |plant_type, ident, counts|
  counts.each_with_index do |count, i|
    PlantLevel.create(level: "#{i + 1}", deposit: "0", price: {"kadry" => 1},
                      formulas: [{from: [], to: [{identificator: ident, count: count}], max_product: [{identificator: ident, count: count}]}],
                      plant_type_id: plant_type.id)
  end
end



# Предприятия (7) и Университет с иконками (Remix Icon)
kombinat_sinteticheskih = PlantType.create(pt_attrs.call("Комбинат синтетических изделий", per, "ri-settings-3-line"))
kompozitnyj_ceh = PlantType.create(pt_attrs.call("Композитный цех", per, "ri-stack-line"))
uchastok_plastmassovyh = PlantType.create(pt_attrs.call("Участок пластмассовых изделий", per, "ri-box-3-line"))
himlaboratoriya = PlantType.create(pt_attrs.call("Химлаборатория", per, "ri-flask-line"))
shvejnaya = PlantType.create(pt_attrs.call("Швейная", per, "ri-t-shirt-line"))
radioatele = PlantType.create(pt_attrs.call("Радиоателье", per, "ri-radio-line"))

universitet = PlantType.create(pt_attrs.call("Университет", univer, "ri-graduation-cap-line"))




# Комбинат синтетических изделий (artel.xlsx: макс из столбца Округл 20/50/130)
# Уровень 1: ИС 1100, цена Изоляция 10 + Фарм. преп 2 + Кадры 2 | Из: Полимеры 7, Каучук 5 → В: Рез. тех. изделия 1
PlantLevel.create(level: "1", deposit: "1100", price: {"izolyaciya" => 10, "farm_prep" => 2, "kadry" => 2},
                  formulas: [{from:         [{identificator: "polimery", count: 7}, {identificator: "kauchuk", count: 5}],
                            to:           [{identificator: "rez_teh_izd", count: 1}],
                            max_product:  [{identificator: "rez_teh_izd", count: 20}]}],
                  plant_type_id: kombinat_sinteticheskih.id)

# Уровень 2: ИС 3300, Изоляция 15, Фарм. преп 4, Кадры 4 | Полимеры 6, Каучук 4 → Рез. тех. изделия 1 (макс 50)
PlantLevel.create(level: "2", deposit: "3300", price: {"izolyaciya" => 15, "farm_prep" => 4, "kadry" => 2},
                  formulas: [{from:         [{identificator: "polimery", count: 6}, {identificator: "kauchuk", count: 4}],
                            to:           [{identificator: "rez_teh_izd", count: 1}],
                            max_product:  [{identificator: "rez_teh_izd", count: 50}]}],
                  plant_type_id: kombinat_sinteticheskih.id)

# Уровень 3: ИС 8000, Изоляция 50, Фарм. преп 8, Кадры 8 | Полимеры 4, Каучук 3 → Рез. тех. изделия 1 (макс 130)
PlantLevel.create(level: "3", deposit: "8000", price: {"izolyaciya" => 50, "farm_prep" => 8, "kadry" => 4},
                  formulas: [{from:         [{identificator: "polimery", count: 4}, {identificator: "kauchuk", count: 3}],
                            to:           [{identificator: "rez_teh_izd", count: 1}],
                            max_product:  [{identificator: "rez_teh_izd", count: 130}]}],
                  plant_type_id: kombinat_sinteticheskih.id)


# Композитный цех (artel.xlsx: Полимеры+Эл.комп+Кадры → Изоляция+Металл → Пластины, Округл 20/50/140)
PlantLevel.create(level: "1", deposit: "1200", price: {"polimery" => 50, "el_komp" => 5, "kadry" => 2},
                  formulas: [{from:         [{identificator: "izolyaciya", count: 3}, {identificator: "metall", count: 2}],
                            to:           [{identificator: "plastiny", count: 1}],
                            max_product:  [{identificator: "plastiny", count: 20}]}],
                  plant_type_id: kompozitnyj_ceh.id)

PlantLevel.create(level: "2", deposit: "3800", price: {"polimery" => 100, "el_komp" => 15, "kadry" => 2},
                  formulas: [{from:         [{identificator: "izolyaciya", count: 2}, {identificator: "metall", count: 2}],
                            to:           [{identificator: "plastiny", count: 1}],
                            max_product:  [{identificator: "plastiny", count: 50}]}],
                  plant_type_id: kompozitnyj_ceh.id)

PlantLevel.create(level: "3", deposit: "10100", price: {"polimery" => 360, "el_komp" => 30, "kadry" => 4},
                  formulas: [{from:         [{identificator: "izolyaciya", count: 2}, {identificator: "metall", count: 3}],
                            to:           [{identificator: "plastiny", count: 2}],
                            max_product:  [{identificator: "plastiny", count: 140}]}],
                  plant_type_id: kompozitnyj_ceh.id)


# Участок пластмассовых изделий (artel.xlsx: Каучук+Одежда+Кадры → Полимеры+Реагенты → Пласт. изд, Округл 50/110/330)
PlantLevel.create(level: "1", deposit: "2000", price: {"kauchuk" => 80, "odezhda" => 3, "kadry" => 2},
                  formulas: [{from:         [{identificator: "polimery", count: 5}, {identificator: "reagenty", count: 5}],
                            to:           [{identificator: "plast_izd", count: 1}],
                            max_product:  [{identificator: "plast_izd", count: 50}]}],
                  plant_type_id: uchastok_plastmassovyh.id)

PlantLevel.create(level: "2", deposit: "5900", price: {"kauchuk" => 150, "odezhda" => 6, "kadry" => 2},
                  formulas: [{from:         [{identificator: "polimery", count: 4}, {identificator: "reagenty", count: 4}],
                            to:           [{identificator: "plast_izd", count: 1}],
                            max_product:  [{identificator: "plast_izd", count: 110}]}],
                  plant_type_id: uchastok_plastmassovyh.id)

PlantLevel.create(level: "3", deposit: "12400", price: {"kauchuk" => 200, "odezhda" => 12, "kadry" => 4},
                  formulas: [{from:         [{identificator: "polimery", count: 3}, {identificator: "reagenty", count: 3}],
                            to:           [{identificator: "plast_izd", count: 1}],
                            max_product:  [{identificator: "plast_izd", count: 330}]}],
                  plant_type_id: uchastok_plastmassovyh.id)



# Химлаборатория (artel.xlsx: Ткань+Реагенты+Кадры → Реагенты → Фарм. преп, Округл 70/130/380)
PlantLevel.create(level: "1", deposit: "800", price: {"tkan" => 20, "reagenty" => 50, "kadry" => 1},
                  formulas: [{from:         [{identificator: "reagenty", count: 8}],
                            to:           [{identificator: "farm_prep", count: 1}],
                            max_product:  [{identificator: "farm_prep", count: 70}]}],
                  plant_type_id: himlaboratoriya.id)

PlantLevel.create(level: "2", deposit: "3100", price: {"tkan" => 40, "reagenty" => 110, "kadry" => 2},
                  formulas: [{from:         [{identificator: "reagenty", count: 6}],
                            to:           [{identificator: "farm_prep", count: 1}],
                            max_product:  [{identificator: "farm_prep", count: 130}]}],
                  plant_type_id: himlaboratoriya.id)

PlantLevel.create(level: "3", deposit: "7200", price: {"tkan" => 80, "reagenty" => 220, "kadry" => 2},
                  formulas: [{from:         [{identificator: "reagenty", count: 4}],
                            to:           [{identificator: "farm_prep", count: 1}],
                            max_product:  [{identificator: "farm_prep", count: 380}]}],
                  plant_type_id: himlaboratoriya.id)


# Швейная (artel.xlsx: Ткань+Металл+Кадры → Ткань → Одежда, Округл 30/100/410)
PlantLevel.create(level: "1", deposit: "900", price: {"tkan" => 15, "metall" => 10, "kadry" => 1},
                  formulas: [{from:         [{identificator: "tkan", count: 4}],
                            to:           [{identificator: "odezhda", count: 1}],
                            max_product:  [{identificator: "odezhda", count: 30}]}],
                  plant_type_id: shvejnaya.id)

PlantLevel.create(level: "2", deposit: "3100", price: {"tkan" => 30, "metall" => 20, "kadry" => 2},
                  formulas: [{from:         [{identificator: "tkan", count: 4}],
                            to:           [{identificator: "odezhda", count: 2}],
                            max_product:  [{identificator: "odezhda", count: 100}]}],
                  plant_type_id: shvejnaya.id)

PlantLevel.create(level: "3", deposit: "6900", price: {"tkan" => 70, "metall" => 30, "kadry" => 2},
                  formulas: [{from:         [{identificator: "tkan", count: 4}],
                            to:           [{identificator: "odezhda", count: 3}],
                            max_product:  [{identificator: "odezhda", count: 410}]}],
                  plant_type_id: shvejnaya.id)




# Радиоателье (artel.xlsx: Металл+Реагенты+Кадры → Металл → Эл. комп, Округл 70/210/930)
PlantLevel.create(level: "1", deposit: "700", price: {"metall" => 9, "reagenty" => 15, "kadry" => 1},
                  formulas: [{from:         [{identificator: "metall", count: 2}],
                            to:           [{identificator: "el_komp", count: 4}],
                            max_product:  [{identificator: "el_komp", count: 70}]}],
                  plant_type_id: radioatele.id)

PlantLevel.create(level: "2", deposit: "2600", price: {"metall" => 18, "reagenty" => 29, "kadry" => 2},
                  formulas: [{from:         [{identificator: "metall", count: 2}],
                            to:           [{identificator: "el_komp", count: 6}],
                            max_product:  [{identificator: "el_komp", count: 210}]}],
                  plant_type_id: radioatele.id)

PlantLevel.create(level: "3", deposit: "6000", price: {"metall" => 35, "reagenty" => 58, "kadry" => 2},
                  formulas: [{from:         [{identificator: "metall", count: 2}],
                            to:           [{identificator: "el_komp", count: 9}],
                            max_product:  [{identificator: "el_komp", count: 930}]}],
                  plant_type_id: radioatele.id)


PlantLevel.create(level: "1", deposit: "0", price: {},
                  formulas: [{from:         [],
                            to:           [{identificator: "kadry", count: 2}],
                            max_product:  [{identificator: "kadry", count: 2}]}],
                  plant_type_id: universitet.id)
PlantLevel.create(level: "2", deposit: "0", price: {"odezhda" => 5, "el_komp" => 12, "farm_prep" => 5},
                  formulas: [{from:         [],
                            to:           [{identificator: "kadry", count: 4}],
                            max_product:  [{identificator: "kadry", count: 4}]}],
                  plant_type_id: universitet.id)

PlantLevel.create(level: "3", deposit: "0", price: {"odezhda" => 10, "el_komp" => 25, "farm_prep" => 10},
                  formulas: [{from:         [],
                            to:           [{identificator: "kadry", count: 6}],
                            max_product:  [{identificator: "kadry", count: 6}]}],
                  plant_type_id: universitet.id)


