# ==========================================
# Тестовые данные для купцов-игроков
# Запускается после 5_economics.rb (гильдии, предприятия, PlantPlace уже созданы)
# ==========================================

guilds = Guild.order(:id).first(3)
zabavniki  = guilds[0]  # Забавники
kamenshiki = guilds[1]  # Каменщики
pivovary   = guilds[2]  # Пивовары

merchants = Player.where(player_type: PlayerType.find_by(name: "Купец"))
             .where.not(name: "КУПЕЦ") # не трогаем обязательного
             .order(:id)

zabavnik  = merchants.find { |m| m.name == "Забавник"  }
kamenshik = merchants.find { |m| m.name == "Каменщик"  }
pivovar   = merchants.find { |m| m.name == "Пивовар"   }
volny     = merchants.find { |m| m.name == "Вольный"   }
strannik  = merchants.find { |m| m.name == "Странник"  }

# Назначаем гильдийных купцов в гильдии (вольные остаются без guild_id)
[[zabavnik,  zabavniki],
 [kamenshik, kamenshiki],
 [pivovar,   pivovary],
].each do |player, guild|
  next unless player && guild
  player.update!(guild: guild)
end

# ---- ResourceItem helper ----
def set_resource_items(subject, resources_hash)
  resources_hash.each do |identificator, count|
    ResourceItem.find_or_initialize_by(
      economic_subject: subject,
      identificator:    identificator.to_s
    ).update!(count: count)
  end
end

# ---- Ресурсы: гильдийные купцы → ресурсы на гильдию ----

# Забавники: лесоторговля
set_resource_items(zabavniki, {
  gold: 5000, timber: 300, boards: 150, grain: 200, food: 40
}) if zabavniki

# Каменщики: камень и металл
set_resource_items(kamenshiki, {
  gold: 3000, stone: 200, stone_brick: 80, metal: 40, tools: 15
}) if kamenshiki

# Пивовары: зерно и мука
set_resource_items(pivovary, {
  gold: 100000, grain: 2000, flour: 2000, food: 600, meat: 300, stone: 2000, stone_brick: 800, metal: 400, tools: 1500, timber: 3000, boards: 1500
}) if pivovary

# ---- Ресурсы: вольные купцы → ресурсы на игрока ----

# Вольный — смешанные товары
set_resource_items(volny, {
  gold: 6000, boards: 100, tools: 25, metal: 20, grain: 100, timber: 50
}) if volny

# Странник — металл и оружие
set_resource_items(strannik, {
  gold: 2500, metal: 80, metal_ore: 300, tools: 40, weapon: 10, boards: 60
}) if strannik

# ---- Предприятия ----
def plant_level(plant_type_name, lvl)
  pt = PlantType.find_by(name: plant_type_name)
  return nil unless pt
  PlantLevel.find_by(plant_type: pt, level: lvl.to_s)
end

def find_place(category_name)
  cat = PlantCategory.find_by(name: category_name)
  PlantPlace.where(plant_category: cat).first
end

per_place = find_place("Перерабатывающее")
dob_place = find_place("Добывающее")

# Забавники: Делянка ур.2 + Лесопилка ур.1 — принадлежат гильдии
if zabavniki
  pl1 = plant_level("Делянка", 2)
  pl2 = plant_level("Лесопилка", 1)
  Plant.create!(plant_level: pl1, plant_place: dob_place, economic_subject: zabavniki,  params: { "produced" => [] }) if pl1 && dob_place
  Plant.create!(plant_level: pl2, plant_place: per_place, economic_subject: zabavniki,  params: { "produced" => [] }) if pl2 && per_place
end

# Каменщики: Каменоломня ур.1 + Мастерская каменотёса ур.1 — принадлежат гильдии
if kamenshiki
  pl1 = plant_level("Каменоломня", 1)
  pl2 = plant_level("Мастерская каменотёса", 1)
  Plant.create!(plant_level: pl1, plant_place: dob_place, economic_subject: kamenshiki, params: { "produced" => [] }) if pl1 && dob_place
  Plant.create!(plant_level: pl2, plant_place: per_place, economic_subject: kamenshiki, params: { "produced" => [] }) if pl2 && per_place
end

# Пивовары: Зерновые поля ур.1 + Мельница ур.1 — принадлежат гильдии
if pivovary
  pl1 = plant_level("Зерновые поля", 1)
  pl2 = plant_level("Мельница", 1)
  Plant.create!(plant_level: pl1, plant_place: dob_place, economic_subject: pivovary,   params: { "produced" => [] }) if pl1 && dob_place
  Plant.create!(plant_level: pl2, plant_place: per_place, economic_subject: pivovary,   params: { "produced" => [] }) if pl2 && per_place
end

# Вольный: Ферма ур.1 — принадлежит игроку
if volny
  pl1 = plant_level("Ферма", 1)
  Plant.create!(plant_level: pl1, plant_place: dob_place, economic_subject: volny,      params: { "produced" => [] }) if pl1 && dob_place
end

# Странник: Железный рудник ур.1 + Плавильня ур.1 + Кузница ур.1 — принадлежат игроку
if strannik
  pl1 = plant_level("Железный рудник", 1)
  pl2 = plant_level("Плавильня", 1)
  pl3 = plant_level("Кузница", 1)
  Plant.create!(plant_level: pl1, plant_place: dob_place, economic_subject: strannik,   params: { "produced" => [] }) if pl1 && dob_place
  Plant.create!(plant_level: pl2, plant_place: per_place, economic_subject: strannik,   params: { "produced" => [] }) if pl2 && per_place
  Plant.create!(plant_level: pl3, plant_place: per_place, economic_subject: strannik,   params: { "produced" => [] }) if pl3 && per_place
end
