# Знать и города Великого Новгорода (п. 1 и п. 2).
#
# п. 1: знатных игроков за Новгород в ядре быть не должно — движок удаляет
# строки, созданные сидами ядра, и создаёт свой состав совета.
# п. 2: города Новгородской земли распределены между знатью так, чтобы доход
# был более-менее равным.
puts "[many_teams] знать и города Великого Новгорода"

novgorod = Country.find_by(id: Country::NOVGOROD)
if novgorod.nil?
  puts "  ! государство «Великий Новгород» (id=#{Country::NOVGOROD}) не найдено — пропущено"
else
  noble_type = PlayerType.find_by(name: "Знать")

  # --- п. 1: убрать состав из ядра ---
  core_nobles = Player.where(country_id: novgorod.id)
  core_nobles = core_nobles.where(player_type_id: noble_type.id) if noble_type
  core_nobles = core_nobles.to_a

  if core_nobles.any?
    InfluenceItem.where(player_id: core_nobles.map(&:id)).delete_all
    PoliticalAction.where(player_id: core_nobles.map(&:id)).delete_all
    core_nobles.each(&:destroy)
    puts "  из ядра убрано знатных за Новгород: #{core_nobles.size}"
  end

  # --- п. 2: города в землях Новгорода, тип 1 («Город», доход 5 000) ---
  # п. 2: «все типа 1» — тип поселения id=1 (в ядре это «Город»)
  town_type = SettlementType.find_by(id: 1) || SettlementType.find_by(name: "Город")
  new_cities = [
    ["Водская земля", "Ладога"],
    ["Обонежье", "Кемь"],
    ["Обонежье", "Каргополь"],
    ["Подвинье", "Орлец"],
    ["Канинская земля", "Изьма"]
  ]

  new_cities.each do |region_name, city_name|
    region = Region.find_by(name: region_name, country_id: novgorod.id) || Region.find_by(name: region_name)
    if region.nil?
      puts "  ! регион «#{region_name}» не найден — город «#{city_name}» пропущен"
      next
    end

    city = Settlement.find_or_initialize_by(name: city_name, region_id: region.id)
    city.settlement_type = town_type if town_type
    city.params = (city.params || {}).merge("open_gate" => false)
    city.save!
  end

  # --- типы поселений: столица государства и города ---
  # Столица Новгорода — только Великий Новгород (тип 2, «Столица», доход
  # 10 000). Все прочие поселения государства — города (тип 1, «Город»,
  # доход 5 000), в том числе прежние региональные центры Псков, Нюхча,
  # Холмогоры и Усогорск. В ядре у этих поселений другой тип: четыре «Земля»
  # (3) и один «Столичная земля» (4) — на регион приходился ровно один город
  # и отдельной столичной сетки не было.
  capital_type = SettlementType.find_by(id: 2) || SettlementType.find_by(name: "Столица")
  capital_names = ["Великий Новгород"]

  novgorod_settlements = Settlement.joins(:region).where(regions: { country_id: novgorod.id })
  novgorod_settlements.each do |settlement|
    type = capital_names.include?(settlement.name) ? capital_type : town_type
    next if type.nil? || settlement.settlement_type_id == type.id

    settlement.update!(settlement_type: type)
  end

  puts "  столица (тип 2): #{Settlement.joins(:region).where(regions: { country_id: novgorod.id }, settlement_type_id: capital_type&.id).order(:name).pluck(:name).join(', ')}"
  puts "  города (тип 1): #{Settlement.joins(:region).where(regions: { country_id: novgorod.id }, settlement_type_id: town_type&.id).order(:name).pluck(:name).join(', ')}"

  # --- крепости: только Псков 2 уровня и Великий Новгород 1 уровня ---
  # Ядро ставит оборонительные постройки по колонке «Крепость» из
  # countries.csv, и у Новгорода их пять: Великий Новгород 2, Псков 2,
  # Нюхча 1, Холмогоры 1, Усогорск 1. По правилам игры за Новгород остаются
  # только две: Псков — 2 уровень («Крепость»), Великий Новгород — 1 уровень
  # («Форт»). Общий countries.csv не правим: он раскатывается всем играм
  # (ядро, artel, vassals), поэтому раскладку приводим сидом движка.
  kremlin_type = BuildingType.find_by(name: "Кремль")
  if kremlin_type
    keep_keeps = { "Псков" => 2, "Великий Новгород" => 1 }

    novgorod_settlements.to_a.each do |settlement|
      settlement.buildings.select { |building| building.building_level&.building_type_id == kremlin_type.id }.each(&:destroy)
    end

    keep_keeps.each do |city_name, level|
      city = Settlement.find_by(name: city_name)
      if city.nil?
        puts "  ! город «#{city_name}» не найден — крепость пропущена"
        next
      end

      building_level = BuildingLevel.find_by(building_type_id: kremlin_type.id, level: level)
      if building_level.nil?
        puts "  ! уровень #{level} типа «Кремль» не найден — крепость в «#{city_name}» пропущена"
        next
      end

      Building.create(building_level: building_level, settlement: city)
    end

    keeps = Settlement.joins(:region).where(regions: { country_id: novgorod.id }).to_a.flat_map do |settlement|
      settlement.buildings.select { |building| building.building_level&.building_type_id == kremlin_type.id }
                .map { |building| "#{settlement.name} #{building.building_level.level}" }
    end
    puts "  крепости: #{keeps.join(', ')}"
  else
    puts "  ! тип построек «Кремль» не найден — крепости не тронуты"
  end

  # --- состав совета и раскладка городов ---
  # Владения Новгорода (файл заказчика, раздел «Владения Новгород»): у каждой
  # семьи ровно одно владение, Ладога и Орлец — «Б/х», без хозяина. Доход:
  # столица 10 000 у князя и семь владений по 5 000 — 45 000 на восемь
  # должностей совета.
  council = [
    { name: "Борецкий",    family: "Борецкие",    jobs: [1], cities: ["Великий Новгород"] },
    { name: "Мишинич",     family: "Мишиничи",    jobs: [2], cities: ["Кемь"] },
    { name: "Онцифорович", family: "Онцифоровичи", jobs: [3], cities: ["Нюхча"] },
    { name: "Прокшинич",   family: "Прокшиничи",  jobs: [4], cities: ["Каргополь"] },
    { name: "Своеземцев",  family: "Своеземцевы", jobs: [5], cities: ["Холмогоры"] },
    { name: "Есипов",      family: "Есиповы",     jobs: [6], cities: ["Усогорск"] },
    { name: "Лошинский",   family: "Лошинские",   jobs: [7], cities: ["Псков"] },
    { name: "Овинов",      family: "Овиновы",     jobs: [8], cities: ["Изьма"] }
  ]

  # «Б/х» во владениях Новгорода: города остаются за государством, но без
  # владельца — сид снимает хозяина, оставшегося от прежней раскладки.
  ownerless_cities = ["Ладога", "Орлец"]

  incomes = []

  council.each_with_index do |entry, index|
    family = Family.find_or_create_by(name: entry[:family])
    job = Job.find_by(id: entry[:jobs].first)

    identificator = Player.generate_identificator(entry[:name], nil, family.name, job&.name, "MANY_TEAMS_#{index}")

    player = Player.find_or_initialize_by(identificator: identificator)
    player.name = entry[:name]
    player.player_type = noble_type if noble_type
    player.family = family
    player.country_id = novgorod.id
    player.jobs = [job] if job
    player.params = (player.params || {}).merge("income_taken" => false)
    player.save!
    InfluenceItem.add(0, "Ручная правка", player) if player.influence_items.empty?

    entry[:cities].each do |city_name|
      city = Settlement.find_by(name: city_name)
      if city.nil?
        puts "  ! город «#{city_name}» не найден"
        next
      end
      city.update!(player_id: player.id)
    end

    income = Settlement.where(player_id: player.id).sum { |settlement| settlement.income }
    incomes << [player.name, income]
    puts "  #{job&.name}: #{player.name} — доход #{income}"
  end

  # --- «Б/х»: Ладога и Орлец остаются без хозяина ---
  ownerless_cities.each do |city_name|
    city = Settlement.find_by(name: city_name)
    next if city.nil? || city.player_id.nil?

    city.update!(player_id: nil)
  end
  puts "  без хозяина: #{Settlement.joins(:region).where(regions: { country_id: novgorod.id }, player_id: nil).order(:name).pluck(:name).join(', ')}"

  puts "  городов у знати Новгорода: #{Settlement.joins(:region).where(regions: { country_id: novgorod.id }).where.not(player_id: nil).count}"
  puts "  доход по знати: #{incomes.map { |row| "#{row[0]} #{row[1]}" }.join(', ')}"
  puts "  разброс дохода: #{incomes.map { |row| row[1] }.minmax.join('…')}"

  # --- церковь митрополита и ручная правка ОП ---
  # Митрополит получает в своём владении церковь 3 уровня («Монастырь», +6 к
  # общественному порядку земли), а по этой земле ставится ручная правка ОП −6:
  # эффект церкви гасится, земля стартует с нулевым порядком.
  metropolitan = Player.where(country_id: novgorod.id).detect do |player|
    player.jobs.any? { |job| job.name == "Митрополит" }
  end
  religious_type = BuildingType.find_by(id: BuildingType::RELIGIOUS) || BuildingType.find_by(name: "Церковь")
  church_level = BuildingLevel.find_by(building_type_id: religious_type&.id, level: 3)
  metropolitan_city = metropolitan && Settlement.where(player_id: metropolitan.id).first

  if metropolitan.nil? || metropolitan_city.nil? || church_level.nil?
    puts "  ! митрополит, его владение или 3 уровень церкви не найдены — церковь не поставлена"
  else
    # Церковь во владении одна: прежние религиозные постройки снимаются, чтобы
    # повторный запуск не копил эффект общественного порядка.
    metropolitan_city.buildings
                     .select { |building| building.building_level&.building_type_id == religious_type.id }
                     .each(&:destroy)
    Building.create(building_level: church_level, settlement: metropolitan_city)

    region = metropolitan_city.region
    po_value = -church_level.params["public_order"].to_i
    unless region.public_order_items.exists?(comment: "Ручная правка", value: po_value)
      PublicOrderItem.add(po_value, "Ручная правка", region)
    end

    puts "  церковь митрополита: #{metropolitan.name} — «#{church_level.name}» (3 ур.) в #{metropolitan_city.name} (#{region.name})"
    puts "  ОП земли «#{region.name}»: церковь #{church_level.params["public_order"]}, ручная правка #{po_value}, итого #{region.show_overall_po(novgorod)}"
  end
end
