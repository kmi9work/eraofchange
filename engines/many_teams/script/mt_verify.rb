# Полная проверка движка many_teams по пунктам ТЗ.
# Запуск: ACTIVE_GAME=many-teams bin/rails runner script/mt_verify.rb
$fails = []
def check(name)
  ok = yield
  puts "#{ok ? 'PASS' : 'FAIL'}  #{name}"
  $fails << name unless ok
  ok
rescue => e
  puts "FAIL  #{name} — #{e.class}: #{e.message}"
  $fails << "#{name} (#{e.class})"
  false
end

puts "=== 0. окружение"
puts "ACTIVE_GAME=#{ENV['ACTIVE_GAME'].inspect} ManyTeams.active?=#{ManyTeams.active?}"
puts "стран: #{Country.count}, гильдий: #{Guild.count}, игроков Новгорода: #{Player.where(country_id: Country::NOVGOROD).count}"

novgorod = Country.find(Country::NOVGOROD)
guild = Guild.order(:id).first
own_country = Country.find(guild.country_id)

puts "\n=== п.1 знать Новгорода только в движке"
# Купцы Новгорода создаются отдельным сидом движка (гильдии, п. 4 ТЗ этапа 2),
# поэтому считаем только знать: у Новгорода их 8, купцов — 6.
novgorod_nobles = Player.where(country_id: novgorod.id, player_type_id: PlayerType.find_by(name: "Знать")&.id)
check("ядро не создаёт знати Новгорода (8 человек из сида движка)") do
  novgorod_nobles.count == 8
end
check("все знатные Новгорода — типа «Знать»") do
  novgorod_nobles.all? { |p| p.player_type&.name == "Знать" }
end

puts "\n=== п.2 города Новгорода"
# Раскладка владений по файлу заказчика («Владения Новгород»): у каждой семьи
# одно владение, Ладога и Орлец — «Б/х», без хозяина.
owned_cities = {
  "Великий Новгород" => "Борецкий",
  "Кемь" => "Мишинич",
  "Нюхча" => "Онцифорович",
  "Каргополь" => "Прокшинич",
  "Холмогоры" => "Своеземцев",
  "Усогорск" => "Есипов",
  "Псков" => "Лошинский",
  "Изьма" => "Овинов"
}
owned_cities.each do |city_name, owner_name|
  check("«#{city_name}» — владение #{owner_name}") do
    city = Settlement.find_by(name: city_name)
    city && city.player&.name == owner_name && city.player.country_id == novgorod.id
  end
end
check("Ладога и Орлец — без хозяина (Б/х), но в землях Новгорода") do
  %w[Ладога Орлец].all? do |name|
    city = Settlement.find_by(name: name)
    city && city.player_id.nil? && city.region&.country_id == novgorod.id
  end
end
check("столица Новгорода — Великий Новгород, тип 2 («Столица»)") do
  names = ["Великий Новгород"]
  names.all? { |name| Settlement.find_by(name: name)&.settlement_type&.name == "Столица" } &&
    Settlement.joins(:region).where(regions: { country_id: novgorod.id }, settlement_type_id: 2).count == names.size
end
check("остальные поселения Новгорода — тип 1 («Город»)") do
  others = Settlement.joins(:region).where(regions: { country_id: novgorod.id }).to_a
                     .reject { |s| s.settlement_type_id == 2 }
  others.any? && others.all? { |s| s.settlement_type&.name == "Город" }
end
check("доход по знати Новгорода 5 000…10 000") do
  incomes = novgorod_nobles.map do |p|
    Settlement.where(player_id: p.id).sum { |s| s.income }
  end
  puts "      доходы: #{incomes.sort.inspect}"
  incomes.min >= 5_000 && incomes.max <= 10_000
end

puts "\n=== крепости Новгорода"
# По правилам за Новгород остаются только две крепости: Псков — 2 уровень
# («Крепость»), Великий Новгород — 1 уровень («Форт»).
check("крепости только в Пскове (2 ур.) и Великом Новгороде (1 ур.)") do
  keeps = Settlement.joins(:region).where(regions: { country_id: novgorod.id }).to_a.flat_map do |settlement|
    settlement.buildings.select { |b| b.building_level&.building_type&.name == "Кремль" }
              .map { |b| [settlement.name, b.building_level.level] }
  end
  puts "      крепости: #{keeps.map { |name, level| "#{name} #{level}" }.join(', ')}"
  keeps.sort == [["Великий Новгород", 1], ["Псков", 2]].sort
end

puts "\n=== церковь митрополита и общественный порядок земли"
# Митрополит получает в своём владении церковь 3 уровня («Монастырь», +6 к
# общественному порядку земли), а по этой земле — ручная правка ОП −6: эффект
# церкви гасится, земля стартует с нулевым порядком.
metropolitan = Player.where(country_id: novgorod.id).detect { |p| p.jobs.any? { |j| j.name == "Митрополит" } }
metropolitan_city = metropolitan && Settlement.where(player_id: metropolitan.id).first
metropolitan_region = metropolitan_city&.region
check("у митрополита Новгорода церковь 3 уровня в его владении") do
  church = metropolitan_city&.buildings&.map(&:building_level)&.detect { |l| l.building_type_id == BuildingType::RELIGIOUS }
  puts "      #{metropolitan&.name} — #{metropolitan_city&.name}: #{church&.name} (#{church&.level})"
  church&.level == 3 && church&.building_type&.name == "Церковь"
end
check("ручная правка ОП −6 в земле митрополита гасит эффект церкви") do
  church_po = metropolitan_region&.inf_buildings_on_po.to_i
  manual_po = metropolitan_region&.public_order_items&.where(comment: "Ручная правка")&.sum(:value).to_i
  puts "      #{metropolitan_region&.name}: церковь +#{church_po}, ручная правка #{manual_po}, ОП земли #{metropolitan_region&.show_overall_po(novgorod)}"
  church_po.positive? && (church_po + manual_po).zero?
end

puts "\n=== сиды: гильдии, купцы и предприятия Новгорода"
novgorod_guilds = Guild.where(country_id: novgorod.id).order(:id)
check("у Новгорода 3 гильдии (сид движка)") { novgorod_guilds.count == 3 }
check("каждая гильдия Новгорода с двумя купцами типа «Купец»") do
  novgorod_guilds.all? do |g|
    g.players.count == 2 && g.players.all? { |p| p.player_type&.name == "Купец" && p.country_id == novgorod.id }
  end
end
check("у каждой гильдии добывающее и перерабатывающее предприятие в землях Новгорода") do
  novgorod_guilds.all? do |g|
    plants = g.plants.to_a
    plants.size == 2 &&
      plants.any? { |p| p.plant_level&.plant_type&.plant_category&.is_extractive } &&
      plants.any? { |p| !p.plant_level&.plant_type&.plant_category&.is_extractive } &&
      plants.all? { |p| p.plant_place&.region&.country_id == novgorod.id }
  end
end
check("у каждой гильдии есть склад ресурсов (включая деньги)") do
  novgorod_guilds.all? do |g|
    items = g.resource_items
    items.exists?(identificator: "gold") && items.sum(:count).positive?
  end
end
check("добыча гильдиям Новгорода по умолчанию открыта в своей стране") do
  novgorod_guilds.all? { |g| ManyTeams::GuildCountryPermission.allowed?(g, novgorod) }
end

puts "\n=== п.3 цены не зависят от отношений"
check("Resource.calculate_cost берёт цену уровня отношений 0") do
  resource = Resource.find_by(identificator: "horses") || Resource.where.not(params: nil).first
  zero_buy = resource.params["buy_price"]["0"].to_i
  zero_sale = resource.params["sale_price"]["0"].to_i
  buy = Resource.calculate_cost("buy", 2, resource)
  sale = Resource.calculate_cost("sale", 2, resource)
  puts "      #{resource.name}: уровень 0 buy=#{zero_buy} sale=#{zero_sale}; " \
       "расчёт buy=#{buy[:cost]} sale=#{sale[:cost]}"
  buy[:cost] == zero_buy * 2 && sale[:cost] == zero_sale * 2
end
check("ZERO_RELATIONS = '0' и метод берёт этот уровень") do
  ManyTeams::Concerns::ResourceClassExtensions::ZERO_RELATIONS == "0"
end

puts "\n=== п.4/5 разрешение гильдии: умолчание и переопределение"
check("по умолчанию строительство и работа открыты в своей стране") do
  ManyTeams::GuildCountryPermission.allowed?(guild, own_country)
end
check("по умолчанию строительство и работа закрыты в чужой стране") do
  !ManyTeams::GuildCountryPermission.allowed?(guild, novgorod)
end
check("таблица разрешений — все гильдии игры, а не только гильдии страны") do
  rows = ManyTeams::GuildCountryPermission.matrix_for(own_country)
  rows.size == Guild.count && rows.map { |row| row[:guild_id] }.sort == Guild.order(:id).pluck(:id)
end
check("в строке таблицы — разрешение только для запрошенной страны") do
  row = ManyTeams::GuildCountryPermission.matrix_for(own_country).find { |item| item[:guild_id] == guild.id }
  row.present? &&
    row[:allowed] == ManyTeams::GuildCountryPermission.allowed?(guild, own_country) &&
    row[:guild_country_name].present?
end
check("переопределение закрывает строительство и работу в своей стране") do
  ManyTeams::GuildCountryPermission.set!(guild, own_country, false)
  ManyTeams::GuildCountryPermission.allowed?(guild, own_country) == false &&
    ManyTeams::GuildCountryPermission.overridden?(guild, own_country)
end
check("сброс возвращает умолчание") do
  ManyTeams::GuildCountryPermission.reset!(guild, own_country)
  ManyTeams::GuildCountryPermission.allowed?(guild, own_country)
end
check("действие «Казначей» set_guild_permission меняет показатель") do
  type = PoliticalActionType.find_by(action: "set_guild_permission")
  job = type&.job
  player = job&.council_players(own_country)&.first
  unless player
    # Казначея в совете нет — назначаем на время проверки
    holder = Player.where(player_type_id: PlayerType.find_by(name: "Знать")&.id).first ||
             Player.first
    holder.jobs << job unless holder.jobs.include?(job)
    player = holder
  end
  action = PoliticalAction.new(political_action_type: type, job: job, player: player,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: { "country_id" => own_country.id, "guild_id" => guild.id, "allowed" => false })
  action.save!
  action.set_guild_permission
  ManyTeams::GuildCountryPermission.allowed?(guild, own_country) == false
ensure
  ManyTeams::GuildCountryPermission.reset!(guild, own_country)
end

puts "\n=== п.6 данные для отметки в era_native"
check("Plant#many_teams_work_forbidden? действует на предприятия любой категории") do
  plants = Plant.where(economic_subject_type: "Guild", economic_subject_id: guild.id).to_a
  if plants.empty?
    puts "      у гильдии нет предприятий — проверка по модели пропущена"
    true
  else
    results = plants.map do |plant|
      country = plant.plant_place&.region&.country
      next nil if country.nil?

      ManyTeams::GuildCountryPermission.set!(guild, country, false)
      forbidden = plant.many_teams_work_forbidden?
      ManyTeams::GuildCountryPermission.reset!(guild, country)
      puts "      #{plant.plant_level&.plant_type&.name} (extractive=#{plant.many_teams_extractive?}): #{forbidden}"
      forbidden
    end.compact
    results.any? && results.all?
  end
end
check("проверка мест строительства расширена движком") do
  PlantPlacesController.ancestors.include?(ManyTeams::Concerns::PlantPlacesControllerExtensions)
end
# Технология «Ремесловые люди» (кузница/ювелирная мастерская) в многострановом
# режиме считается ПО ГОСУДАРСТВУ ЗЕМЛИ, а запрет на экране выбора типа — по
# странам гильдии: гильдии Москвы можно строить в Орде, и открытая там
# технология снимает запрет.
check("технология «Ремесловые люди»: статус по государству земли и по странам гильдии") do
  technology = Technology.find_by(id: Technology::CRAFTSMEN)
  guild_with_country = Guild.where.not(country_id: nil).order(:id).first
  if technology.nil? || guild_with_country.nil?
    puts "      технологии или гильдии с государством нет — пропущено"
    true
  else
    original = technology.technology_items.pluck(:country_id, :value).to_h
    allowed = guild_with_country.many_teams_build_countries

    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.host! "localhost" # иначе ActionDispatch режет запрос как Blocked host

    fetch_places = lambda do
      session.get "/plant_places/available_places", params: { guild_id: guild_with_country.id }
      raise "HTTP #{session.response.status}" unless session.response.status == 200

      JSON.parse(session.response.body)
    end

    begin
      # 1. Технология открыта в одной из разрешённых стран — для гильдии запрета нет.
      technology.technology_items.update_all(value: 0)
      technology.technology_items.where(country_id: allowed.first.id).update_all(value: 1)

      type = fetch_places.call.find { |item| Array(item["technology_requirements"]).any? }
      raise "нет типа предприятия с технологическим требованием" if type.nil?

      requirement = type["technology_requirements"].first
      place_in_allowed = Array(type["available_places"]).find do |place|
        place["region_country_id"] == allowed.first.id
      end
      puts "      открыта в «#{allowed.first.name}»: open=#{requirement['open'].inspect} " \
           "open_anywhere=#{requirement['open_anywhere'].inspect}"
      raise "open_anywhere должен быть true" unless requirement["open_anywhere"] == true
      raise "нет места в разрешённой стране" if place_in_allowed.nil?
      unless Array(place_in_allowed["technology_requirements"]).first&.dig("open") == true
        raise "статус технологии у места в разрешённой стране должен быть открыт"
      end

      # 2. Технология открыта только в стране, где гильдии строить нельзя, но где
      #    есть земля этого типа: для гильдии запрет остаётся, а у места статус
      #    открыт — он считается по государству земли, а не по текущему.
      technology.technology_items.update_all(value: 0)
      allowed_ids = allowed.map(&:id)
      foreign_place = Array(type["available_places"]).find do |place|
        !allowed_ids.include?(place["region_country_id"])
      end

      if foreign_place.nil?
        puts "      места вне разрешённых стран нет — шаг «статус по земле» пропущен"
        true
      else
        technology.technology_items
                  .where(country_id: foreign_place["region_country_id"])
                  .update_all(value: 1)

        data = fetch_places.call
        type_again = data.find { |item| item["plant_type_id"] == type["plant_type_id"] }
        requirement = type_again["technology_requirements"].first
        place_again = Array(type_again["available_places"]).find { |place| place["id"] == foreign_place["id"] }
        place_status = Array(place_again["technology_requirements"]).first&.dig("open")
        puts "      открыта только в «#{place_again['country_name']}», где гильдии строить нельзя: " \
             "open_anywhere=#{requirement['open_anywhere'].inspect}, статус места=#{place_status.inspect}"

        requirement["open_anywhere"] == false && place_status == true
      end
    ensure
      original.each do |country_id, value|
        technology.technology_items.where(country_id: country_id).update_all(value: value)
      end
    end
  end
end

check("«Технические училища» действуют только на землях государства, где открыты") do
  technology = Technology.find_by(id: Technology::TECH_SCHOOLS)
  own_plant = Plant.joins(plant_place: :region).where(regions: { country_id: own_country.id })
                   .where.not(plant_level_id: nil).first
  foreign_plant = Plant.joins(plant_place: :region).where(regions: { country_id: novgorod.id })
                       .where.not(plant_level_id: nil).first
  if technology.nil? || own_plant.nil? || foreign_plant.nil?
    puts "      нет технологии или предприятий в обоих государствах — пропущено"
    true
  else
    original = technology.technology_items.pluck(:country_id, :value).to_h
    begin
      technology.technology_items.update_all(value: 0)
      technology.technology_items.where(country_id: own_country.id).update_all(value: 1)

      level = own_plant.plant_level
      request = [{ "identificator" => "boards", "count" => 100 }]
      own_out = level.feed_to_plant!(request.deep_dup, "from", own_country)["to"].first&.dig("count")
      foreign_out = level.feed_to_plant!(request.deep_dup, "from", novgorod)["to"].first&.dig("count")
      default_out = level.feed_to_plant!(request.deep_dup, "from")["to"].first&.dig("count")

      puts "      открыты в «#{own_country.name}»: предприятие на своих землях #{own_plant.tech_schools_open?}, " \
           "на новгородских #{foreign_plant.tech_schools_open?}; выход 100 → #{own_out} / #{foreign_out} " \
           "(без аргумента — #{default_out})"

      own_plant.tech_schools_open? &&
        !foreign_plant.tech_schools_open? &&
        own_out == foreign_out * 1.5 &&
        default_out == own_out   # без аргумента — текущее государство (прежнее поведение)
    ensure
      original.each { |country_id, value| technology.technology_items.where(country_id: country_id).update_all(value: value) }
    end
  end
end

puts "\n=== п.4 предупреждение, а не запрет: сервер предприятие не блокирует"
check("Plant валиден в чужой стране без разрешения гильдии") do
  template = Plant.where(economic_subject_type: "Guild", economic_subject_id: guild.id).first
  foreign_place = PlantPlace.all.find { |pp| pp.region&.country_id == novgorod.id }
  if template.nil? || foreign_place.nil?
    puts "      нет шаблона предприятия или места в Новгороде — пропущено"
    true
  else
    country = foreign_place.region&.country
    ManyTeams::GuildCountryPermission.set!(guild, country, false)
    plant = Plant.new(plant_level: template.plant_level, plant_place: foreign_place,
                      economic_subject: guild)
    valid = plant.valid?
    puts "      ошибки: #{plant.errors.full_messages.inspect}" unless valid
    ManyTeams::GuildCountryPermission.reset!(guild, country)
    valid
  end
end
check("правило «строить только в странах игроков» к предприятиям не применяется") do
  # Набор «государства игроков» остаётся для «Дашборда» и разведки, но на
  # строительство не влияет (решение заказчика: единственный запрет — от гильдии).
  ManyTeams::PlayerCountry.replace!([own_country.id])
  template = Plant.where(economic_subject_type: "Guild", economic_subject_id: guild.id).first
  foreign_place = PlantPlace.all.find { |pp| pp.region&.country_id == novgorod.id }
  ok = if template.nil? || foreign_place.nil?
         true
       else
         Plant.new(plant_level: template.plant_level, plant_place: foreign_place,
                   economic_subject: guild).valid?
       end
  ManyTeams::PlayerCountry.replace!([])
  ok
end

puts "\n=== п.9 эмбарго страна → гильдия"
check("эмбарго накладывается и снимается") do
  ManyTeams::GuildEmbargo.impose!(novgorod, guild)
  imposed = ManyTeams::GuildEmbargo.embargoed?(novgorod, guild)
  ManyTeams::GuildEmbargo.lift!(novgorod, guild)
  imposed && !ManyTeams::GuildEmbargo.embargoed?(novgorod, guild)
end
check("эмбарго на все гильдии выбранной страны") do
  target = Guild.where.not(country_id: novgorod.id).first || guild
  rows = ManyTeams::GuildEmbargo.impose_country_on_all!(novgorod, Country.find(target.country_id))
  ok = rows.size == Guild.where(country_id: target.country_id).count
  ManyTeams::GuildEmbargo.where(country_id: novgorod.id).delete_all
  ok
end
check("эмбарго накладывает только страна, торгующая на рынке") do
  livonia = Country.find_by(name: "Ливонский орден")
  livonia.present? && livonia.trades_on_market? &&
    !novgorod.trades_on_market? && !own_country.trades_on_market?
end
check("караван гильдии под эмбарго регистрируется: карточку проверяет мастер в клиенте") do
  livonia = Country.find_by(name: "Ливонский орден")
  target_guild = Guild.where(country_id: own_country.id).first
  ManyTeams::GuildEmbargo.impose!(livonia, target_guild)
  result = Caravan.register_caravan({ country_id: livonia.id, guild_id: target_guild.id, is_protected: true })
  ManyTeams::GuildEmbargo.lift!(livonia, target_guild)
  puts "      ответ каравана: #{result[:success] ? 'успех' : result[:error]}"
  result[:success] == true
end
check("рынок: эмбарго подсвечивается по выбранной гильдии, а не по стране") do
  imposer = Country.order(:id).select(&:trades_on_market?)
                    .find { |country| ManyTeams::GuildEmbargo.where(country_id: country.id).none? }
  if imposer.nil?
    puts "      пропуск: у всех торговых государств уже есть эмбарго"
    next true
  end
  first, second = ::Guild.order(:id).limit(2).to_a
  ManyTeams::GuildEmbargo.impose!(imposer, first)
  ok = ManyTeams::GuildEmbargo.for_guild(first).pluck(:country_id).include?(imposer.id) &&
       !ManyTeams::GuildEmbargo.for_guild(second).pluck(:country_id).include?(imposer.id)
  ManyTeams::GuildEmbargo.lift!(imposer, first)
  ok
end

puts "\n=== п.10 «Заморская торговля» и снятие всех эмбарго"
# Решение заказчика: технология — условие правил, а не блокировка. Клиент
# предупреждает, действие выполняется всегда, факт закрытой технологии
# остаётся в params политдействия.
check("без технологии действие выполняется и помечается в params") do
  tech = Technology.find(Technology::OVERSEAS_TRADE)
  tech.technology_items.where(country_id: own_country.id).update_all(value: 0)
  ManyTeams::GuildEmbargo.impose!(novgorod, guild)
  type = PoliticalActionType.find_by(action: "lift_guild_embargoes")
  action = PoliticalAction.new(political_action_type: type, job: type.job,
                               player: type.job&.council_players(own_country)&.first,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: { "guild_id" => guild.id })
  action.save!
  result = action.lift_guild_embargoes
  lifted = Array(result[:lifted_country_ids]).include?(novgorod.id)
  marked = action.reload.params["overseas_trade_open"] == false
  no_rows_left = ManyTeams::GuildEmbargo.where(guild_id: guild.id).count.zero?
  lifted && marked && no_rows_left
end
check("с технологией эмбарго снимаются со всех стран") do
  tech = Technology.find(Technology::OVERSEAS_TRADE)
  tech.open_it(own_country)
  ManyTeams::GuildEmbargo.impose!(novgorod, guild)
  ManyTeams::GuildEmbargo.impose!(Country.find(2), guild)
  type = PoliticalActionType.find_by(action: "lift_guild_embargoes")
  action = PoliticalAction.new(political_action_type: type, job: type.job,
                               player: type.job&.council_players(own_country)&.first,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: { "guild_id" => guild.id })
  action.save!
  action.lift_guild_embargoes
  ManyTeams::GuildEmbargo.where(guild_id: guild.id).count.zero? &&
    action.reload.params["overseas_trade_open"] == true
end

puts "\n=== п.11 Тайный советник"
check("четыре вида разведки с ценами 1000/1000/3000/3000") do
  kinds = ManyTeams::IntelligenceService.kinds
  prices = kinds.map { |kind| [kind[:intel_type], kind[:price]] }
  puts "      #{prices.inspect}"
  prices == [["public_order", 1000], ["rival_relations", 1000],
             ["noble_income", 3000], ["technologies", 3000]]
end
check("отчёт разведки строится для каждого вида") do
  guild.merchants.update_all(guild_id: guild.id) if guild.respond_to?(:merchants)
  ManyTeams::IntelligenceService.kinds.each do |kind_row|
    kind = kind_row[:intel_type]
    type = PoliticalActionType.find_by(action: "conduct_intelligence")
    action = PoliticalAction.new(political_action_type: type, job: type.job,
                                 player: type.job&.council_players(own_country)&.first,
                                 country: own_country, year: GameParameter.current_year, success: 1,
                                 params: { "intel_type" => kind.to_s })
    action.save!
    report = action.conduct_intelligence
    raise "пустой отчёт по #{kind}" if report.nil?
  end
  true
end
check("подрыв стабильности региона: -3") do
  region = Region.first
  type = PoliticalActionType.find_by(action: "undermine_stability")
  action = PoliticalAction.new(political_action_type: type, job: type.job,
                               player: type.job&.council_players(own_country)&.first,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: { "region_id" => region.id })
  action.save!
  before = region.count_items
  action.undermine_stability
  region.reload
  puts "      #{region.name}: общественный порядок #{before} → #{region.count_items}"
  region.count_items == before - 3
end
check("подрыв отношений двух стран: -1") do
  type = PoliticalActionType.find_by(action: "undermine_relations")
  action = PoliticalAction.new(political_action_type: type, job: type.job,
                               player: type.job&.council_players(own_country)&.first,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: {})
  action.save!
  pair = ManyTeams::IntelligenceService.new(action).relation_pair
  # Отношения ограничены диапазоном -2…2: выводим пару в 0, иначе снижение
  # упирается в минимум и проверка «-1» ничего не доказывает.
  current = pair[0].relations(pair[1]).to_i
  pair[0].change_relations(-current, action, partner: pair[1], force: true) unless current.zero?
  before = pair[0].relations(pair[1]).to_i
  action.undermine_relations
  after = pair[0].relations(pair[1]).to_i
  puts "      #{pair[0].name} → #{pair[1].name}: #{before} → #{after}"
  after == before - 1
end
check("пара по умолчанию: первая — зарубежная страна") do
  type = PoliticalActionType.find_by(action: "undermine_relations")
  action = PoliticalAction.new(political_action_type: type, job: type.job,
                               player: type.job&.council_players(own_country)&.first,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: {})
  pair = ManyTeams::IntelligenceService.new(action).relation_pair
  puts "      пара: #{pair[0].name} / #{pair[1].name}"
  pair[0].id != own_country.id
end

puts "\n=== названия технологий в модуле"
# Решение заказчика (many_teams): технология 6 называется «Третий Рим» — в игре
# за любое государство «Москва» в названии неверна. Id и константа не меняются.
check("технология 6 называется «Третий Рим» (в ядре — «Москва — Третий Рим»)") do
  technology = Technology.find_by(id: Technology::MOSCOW_THIRD_ROME)
  puts "      name=#{technology&.name.inspect}"
  technology&.name == "Третий Рим"
end

puts "\n=== итог"
if $fails.empty?
  puts "ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ"
else
  puts "ПРОВАЛЕНО #{ $fails.size }: #{$fails.inspect}"
  exit 1
end
