# Гильдии Великого Новгорода: гильдии, купцы, предприятия и склад ресурсов.
#
# Зачем файл: ядро создаёт три гильдии только для «Руси» (db/seeds/5_economics.rb),
# а купцов, их ресурсы и предприятия — в db/seeds/6_merchants.rb. В игре many-teams
# за Новгород играет отдельная команда, и без своего набора гильдий экраны
# «Экономика», «Купцы», «Дашборд гильдий» и «Грабить караваны» для этой страны пусты.
#
# Состав симметричен «Руси»: три гильдии, у каждой два предприятия (добывающее →
# перерабатывающее), два купца и свой склад. Сырьё — то, что реально есть в землях
# Новгорода:
#
#   Плотники   — Водская земля: делянка (строевой лес) → лесопилка (доски);
#   Кузнецы    — Обонежье: железный рудник (руда) → плавильня (металл);
#   Каменотёсы — Водская земля: каменоломня (камень) → мастерская каменотёса (кирпич).
#
# Добывающих мест (PlantPlace) в этих землях ядро не создаёт: db/seeds/5_economics.rb
# перечисляет «Новгородскую землю», которой в countries.csv уже нет (регион
# называется «Водская земля»), поэтому у Новгорода есть места только под пастбище
# (Подвинье, Псковское княжество) и драгоценную руду (Канинская земля). Сид
# достраивает недостающие места под свои месторождения — без этого добывающее
# предприятие нельзя ни поставить в игре, ни выбрать в клиентах:
# PlantPlacesController#available_places отбирает места по fossil_type.
#
# Сид идемпотентен: гильдия ищется по названию и государству, купец — по
# идентификатору, предприятие — по «гильдия + уровень + место», склад — по паре
# «субъект + ресурс». Повторный db:seed:many_teams не создаёт дублей.
puts "[many_teams] гильдии Великого Новгорода"

novgorod = Country.find_by(id: Country::NOVGOROD)
if novgorod.nil?
  puts "  ! государство «Великий Новгород» (id=#{Country::NOVGOROD}) не найдено — пропущено"
else
  merchant_type = PlayerType.find_by(name: "Купец")
  boss_job = Job.find_by(name: "Глава гульдии")
  extractive = PlantCategory.find_by(name: "Добывающее")
  processing = PlantCategory.find_by(name: "Перерабатывающее")

  # Место предприятия: ищется по имени, региону и категории; недостающие
  # месторождения дописываются в habtm-связь (fossil_types на месте).
  place_for = lambda do |region_name, category, fossil_names|
    region = Region.find_by(name: region_name, country_id: novgorod.id) ||
             Region.find_by(name: region_name)
    if region.nil?
      puts "  ! регион «#{region_name}» не найден — место предприятия пропущено"
      next nil
    end

    kind = category.is_extractive ? "добывающих" : "перерабатывающих"
    place = PlantPlace.find_or_initialize_by(
      name: "Место для #{kind} предприятий в #{region.name}",
      plant_category: category,
      region: region
    )
    place.save! if place.new_record?
    Array(fossil_names).each do |fossil_name|
      fossil = FossilType.find_by(name: fossil_name)
      next if fossil.nil? || place.fossil_types.include?(fossil)
      place.fossil_types << fossil
    end
    place
  end

  level_for = lambda do |plant_type_name, level|
    plant_type = PlantType.find_by(name: plant_type_name)
    if plant_type.nil?
      puts "  ! тип предприятия «#{plant_type_name}» не найден"
      next nil
    end
    plant_level = PlantLevel.find_by(plant_type: plant_type, level: level.to_s)
    puts "  ! уровень #{level} для «#{plant_type_name}» не найден" if plant_level.nil?
    plant_level
  end

  guild_defs = [
    {
      name: "Плотники",
      region: "Водская земля",
      fossils: ["Строевой лес"],
      plants: [["Делянка", "Водская земля", 2], ["Лесопилка", "Водская земля", 2]],
      merchants: [["Плотник", "Плотниковы"], ["Тесляр", "Плотниковы"]],
      resources: { "gold" => 5_000, "timber" => 400, "boards" => 200, "tools" => 10 }
    },
    {
      name: "Кузнецы",
      region: "Обонежье",
      fossils: ["Железная руда"],
      plants: [["Железный рудник", "Обонежье", 2], ["Плавильня", "Обонежье", 2]],
      merchants: [["Кузнец", "Кузнецовы"], ["Оружейник", "Кузнецовы"]],
      resources: { "gold" => 4_500, "metal_ore" => 300, "metal" => 80, "tools" => 20, "weapon" => 5 }
    },
    {
      name: "Каменотёсы",
      region: "Водская земля",
      fossils: ["Камень"],
      plants: [["Каменоломня", "Водская земля", 2], ["Мастерская каменотёса", "Водская земля", 2]],
      merchants: [["Каменотёс", "Каменевы"], ["Кирпичник", "Каменевы"]],
      resources: { "gold" => 4_000, "stone" => 300, "stone_brick" => 90, "tools" => 15 }
    }
  ]

  guild_defs.each_with_index do |definition, index|
    guild = Guild.find_or_initialize_by(name: definition[:name], country_id: novgorod.id)
    guild.params ||= { "caravan_protected" => [] }
    guild.save!

    # ---- купцы гильдии ----
    definition[:merchants].each_with_index do |(name, family_name), merchant_index|
      family = Family.find_or_create_by(name: family_name)
      identificator = Player.generate_identificator(
        name, nil, family.name, boss_job&.name, "MANY_TEAMS_GUILD_#{index}_#{merchant_index}"
      )

      player = Player.find_or_initialize_by(identificator: identificator)
      player.name = name
      player.player_type = merchant_type if merchant_type
      player.family = family
      player.country_id = novgorod.id
      player.guild = guild
      player.jobs = [boss_job] if boss_job
      player.params = (player.params || {}).merge("contraband" => (player.params&.dig("contraband") || []))
      player.save!
    end

    # ---- предприятия: добывающее + перерабатывающее ----
    definition[:plants].each do |plant_type_name, region_name, level|
      plant_level = level_for.call(plant_type_name, level)
      next if plant_level.nil?

      category = plant_level.plant_type.plant_category
      place = place_for.call(region_name, category, definition[:fossils])
      next if place.nil?

      plant = Plant.find_or_initialize_by(
        economic_subject: guild,
        plant_level: plant_level,
        plant_place: place
      )
      plant.params ||= { "produced" => [] }
      if plant.save
        status = plant.previously_new_record? ? "создано" : "уже есть"
      else
        status = "не сохранено: #{plant.errors.full_messages.join(', ')}"
      end
      puts "  #{guild.name}: #{plant_type_name} ур.#{level} — #{place.region.name} (#{status})"
    end

    # ---- склад гильдии ----
    definition[:resources].each do |identificator, count|
      unless Resource.exists?(identificator: identificator)
        puts "  ! ресурс «#{identificator}» отсутствует в справочнике — пропущен"
        next
      end
      ResourceItem.find_or_initialize_by(
        economic_subject: guild,
        identificator: identificator.to_s
      ).update!(count: count)
    end
  end

  # ---- отчёт ----
  guilds = Guild.where(country_id: novgorod.id).order(:id).to_a
  merchants = Player.where(guild_id: guilds.map(&:id)).order(:id)
  plants = Plant.where(economic_subject_type: "Guild", economic_subject_id: guilds.map(&:id))

  puts "  гильдий: #{guilds.size} (#{guilds.map(&:name).join(', ')})"
  puts "  купцов: #{merchants.size} — #{merchants.map { |p| "#{p.name}/#{p.guild&.name}" }.join(', ')}"
  puts "  предприятий: #{plants.count} (добывающих: " \
       "#{plants.count { |plant| plant.plant_level&.plant_type&.plant_category&.is_extractive }})"
  puts "  склад: #{ResourceItem.where(economic_subject_type: 'Guild', economic_subject_id: guilds.map(&:id)).sum(:count)} единиц " \
       "по #{ResourceItem.where(economic_subject_type: 'Guild', economic_subject_id: guilds.map(&:id)).distinct.count(:identificator)} ресурсам"
end
