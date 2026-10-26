# Места для строительства добывающих предприятий (many_teams).
#
# Зачем файл: ядро (`db/seeds/5_economics.rb`) перечисляет земли под добывающие
# предприятия жёстким списком названий, и часть этих названий уже не совпадает
# с `countries.csv` («Новгородская земля» вместо «Водской земли»), поэтому у
# большинства государств строить добывающие предприятия негде. В режиме многих
# команд раскладка задана правилами игры:
#
#   Делянка, железный рудник, каменоломня, поля пшеницы — во ВСЕХ землях
#     Москвы, Великого Новгорода, Большой Орды и Великого княжества Литовского;
#   Ферма — Малая Пермь, Вятская земля, Рязанское княжество, Тверское
#     княжество, Казанское ханство, Королевство Швеция;
#   Драгоценный рудник — Казанское ханство, Крымское ханство, Великая Пермь,
#     Королевство Швеция, Ливонский орден.
#
# «Поля пшеницы» — это месторождение «Плодородная земля» (тип предприятия
# «Зерновые поля»): отдельного типа «Поле пшеницы» в сидах ядра нет.
#
# Сид не только достраивает недостающие места, но и приводит раскладку к
# правилам: в каждом регионе остаётся ОДНО место под добывающие предприятия,
# а его месторождения совпадают со списком — лишние снимаются (пастбище в
# Псковском княжестве и Подвинье, драгоценная руда в Канинской земле и
# Чернигово-Северском княжестве ядро ставит, а правила их там не дают).
# Дубли, которые ядро создаёт по одному на группу месторождений (в землях
# Москвы — «плодородная земля + лес + камень» и отдельно «железная руда»),
# сводятся в одно место: предприятия с дубля переносятся, дубль удаляется.
#
# Идемпотентность: место ищется по региону и категории, месторождения
# назначаются набором (а не дописываются), дубли сводятся к месту с наименьшим
# id — повторный `db:seed:many_teams` не создаёт ни мест, ни дублей.
puts "[many_teams] места для добывающих предприятий"

extractive = PlantCategory.find_by(name: "Добывающее")

if extractive.nil?
  puts "  ! категория «Добывающее» не найдена — сид пропущен"
else
  # Месторождения (FossilType) и предприятие, которое на них строится.
  fossil_names = {
    timber:  "Строевой лес",      # Делянка
    pasture: "Пастбище",          # Ферма
    fertile: "Плодородная земля", # Зерновые поля («поля пшеницы»)
    stone:   "Камень",            # Каменоломня
    iron:    "Железная руда",     # Железный рудник
    gem:     "Драгоценная руда"   # Золотой прииск («драгоценный рудник»)
  }

  fossils = {}
  fossil_names.each do |key, name|
    type = FossilType.find_by(name: name)
    puts "  ! месторождение «#{name}» не найдено — пропущено" if type.nil?
    fossils[key] = type unless type.nil?
  end

  # Цель по регионам: region_id => { region:, keys: [] }.
  region_targets = {}

  add_target = lambda do |region, keys|
    target = (region_targets[region.id] ||= { region: region, keys: [] })
    keys.each { |key| target[:keys] << key unless target[:keys].include?(key) }
  end

  # Все земли четырёх государств — четыре месторождения сразу.
  all_land_keys = [:timber, :iron, :stone, :fertile]
  four_countries = [Country::RUS, Country::NOVGOROD, Country::HORDE, Country::LITHUANIA]
  Country.where(id: four_countries).includes(:regions).each do |country|
    puts "  ! у государства «#{country.name}» нет земель" if country.regions.empty?
    country.regions.each { |region| add_target.call(region, all_land_keys) }
  end

  # Земли по названию (могут отсутствовать в нестандартной базе — не падаем).
  regions_by_name = lambda do |names|
    names.flat_map do |name|
      found = Region.where(name: name).to_a
      puts "  ! земля «#{name}» не найдена — пропущена" if found.empty?
      found
    end
  end

  farm_regions = regions_by_name.call([
    "Малая Пермь", "Вятская земля", "Рязанское княжество",
    "Тверское княжество", "Казанское ханство", "Королевство Швеция"
  ])
  farm_regions.each { |region| add_target.call(region, [:pasture]) }

  gem_regions = regions_by_name.call([
    "Казанское ханство", "Крымское ханство", "Великая Пермь",
    "Королевство Швеция", "Ливонский орден"
  ])
  gem_regions.each { |region| add_target.call(region, [:gem]) }

  created = 0
  consolidated = 0

  region_targets.values.sort_by { |target| target[:region].id }.each do |target|
    region = target[:region]
    target_fossils = target[:keys].map { |key| fossils[key] }.compact.uniq
    if target_fossils.empty?
      puts "  ! #{region.name}: ни одного месторождения в справочнике — пропущено"
      next
    end

    places = PlantPlace.where(region_id: region.id, plant_category_id: extractive.id).order(:id).to_a
    place = places.first

    if place.nil?
      place = PlantPlace.create!(
        name: "Место для добывающих предприятий в #{region.name}",
        plant_category: extractive,
        region: region
      )
      created += 1
      status = "создано"
    else
      status = "уже есть"
    end

    # Дубли ядра: предприятия с лишних мест переносим на основное, места удаляем.
    extras = places - [place]
    moved_plants = 0
    extras.each do |extra|
      moved_plants += Plant.where(plant_place_id: extra.id).update_all(plant_place_id: place.id)
      extra.fossil_types.clear
      extra.destroy
      consolidated += 1
    end

    place.fossil_types = target_fossils

    details = []
    details << "перенесено предприятий: #{moved_plants}" if moved_plants.positive?
    details << "убрано дублей: #{extras.size}" if extras.any?
    puts "  #{region.country&.name} / #{region.name}: #{target_fossils.map(&:name).join(', ')} " \
         "(#{status}#{details.any? ? ", #{details.join(', ')}" : ''})"
  end

  total = PlantPlace.where(plant_category_id: extractive.id).count
  puts "  мест под добывающие предприятия: #{total} " \
       "(создано: #{created}, сведено дублей: #{consolidated})"
end
