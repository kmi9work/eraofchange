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

  # --- состав совета и раскладка городов ---
  # Доход городов: Великий Новгород (Столичная земля) 15 000; Усогорск, Нюхча,
  # Холмогоры, Псков (Земля) по 10 000; пять новых городов по 5 000. Итого 80 000
  # на восемь должностей совета — отсюда раскладка 15 000 / 10 000 ×6 / 5 000.
  council = [
    { name: "Борецкий",    family: "Борецкие",    jobs: [1], cities: ["Великий Новгород"] },
    { name: "Мишинич",     family: "Мишиничи",    jobs: [2], cities: ["Ладога", "Кемь"] },
    { name: "Онцифорович", family: "Онцифоровичи", jobs: [3], cities: ["Нюхча"] },
    { name: "Прокшинич",   family: "Прокшиничи",  jobs: [4], cities: ["Каргополь", "Орлец"] },
    { name: "Своеземцев",  family: "Своеземцевы", jobs: [5], cities: ["Холмогоры"] },
    { name: "Есипов",      family: "Есиповы",     jobs: [6], cities: ["Усогорск"] },
    { name: "Лошинский",   family: "Лошинские",   jobs: [7], cities: ["Псков"] },
    { name: "Овинов",      family: "Овиновы",     jobs: [8], cities: ["Изьма"] }
  ]

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

  puts "  городов у знати Новгорода: #{Settlement.joins(:region).where(regions: { country_id: novgorod.id }).where.not(player_id: nil).count}"
  puts "  доход по знати: #{incomes.map { |row| "#{row[0]} #{row[1]}" }.join(', ')}"
  puts "  разброс дохода: #{incomes.map { |row| row[1] }.minmax.join('…')}"
end
