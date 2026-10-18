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
puts "стран: #{Country.count}, гильдий: #{Guild.count}, знати Новгорода: #{Player.where(country_id: Country::NOVGOROD).count}"

novgorod = Country.find(Country::NOVGOROD)
guild = Guild.order(:id).first
own_country = Country.find(guild.country_id)

puts "\n=== п.1 знать Новгорода только в движке"
check("ядро не создаёт знати Новгорода (8 человек из сида движка)") do
  Player.where(country_id: novgorod.id).count == 8
end
check("все знатные Новгорода — типа «Знать»") do
  Player.where(country_id: novgorod.id).all? { |p| p.player_type&.name == "Знать" }
end

puts "\n=== п.2 города Новгорода"
mapping = {
  "Водская земля" => "Ладога", "Обонежье" => %w[Кемь Каргополь],
  "Подвинье" => "Орлец", "Канинская земля" => "Изьма"
}
mapping.each do |region_name, cities|
  Array(cities).each do |city_name|
    check("«#{city_name}» в регионе «#{region_name}», тип 1, у знати Новгорода") do
      city = Settlement.find_by(name: city_name)
      city && city.region&.name == region_name && city.settlement_type_id == 1 &&
        city.player_id.present? && city.player.country_id == novgorod.id
    end
  end
end
check("доход по знати Новгорода в пределах 5 000…15 000") do
  incomes = Player.where(country_id: novgorod.id).map do |p|
    Settlement.where(player_id: p.id).sum { |s| s.income }
  end
  puts "      доходы: #{incomes.sort.inspect}"
  incomes.min >= 5_000 && incomes.max <= 15_000
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

puts "\n=== п.4/5 добыча: умолчание и переопределение"
check("по умолчанию добыча открыта в своей стране") do
  ManyTeams::GuildExtractionPermission.allowed?(guild, own_country)
end
check("по умолчанию добыча закрыта в чужой стране") do
  !ManyTeams::GuildExtractionPermission.allowed?(guild, novgorod)
end
check("переопределение закрывает добычу в своей стране") do
  ManyTeams::GuildExtractionPermission.set!(guild, own_country, false)
  ManyTeams::GuildExtractionPermission.allowed?(guild, own_country) == false &&
    ManyTeams::GuildExtractionPermission.overridden?(guild, own_country)
end
check("сброс возвращает умолчание") do
  ManyTeams::GuildExtractionPermission.reset!(guild, own_country)
  ManyTeams::GuildExtractionPermission.allowed?(guild, own_country)
end
check("действие «Казначей» set_guild_extraction меняет показатель") do
  type = PoliticalActionType.find_by(action: "set_guild_extraction")
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
  action.set_guild_extraction
  ManyTeams::GuildExtractionPermission.allowed?(guild, own_country) == false
ensure
  ManyTeams::GuildExtractionPermission.reset!(guild, own_country)
end

puts "\n=== п.6 данные для отметки в era_native"
check("Plant#many_teams_extraction_forbidden? читает состояние базы") do
  plant = Plant.where(economic_subject_type: "Guild", economic_subject_id: guild.id).first
  if plant.nil?
    puts "      у гильдии нет предприятий — проверка по модели пропущена"
    true
  else
    country = plant.plant_place&.region&.country
    ManyTeams::GuildExtractionPermission.set!(guild, country, false)
    forbidden = plant.many_teams_extraction_forbidden?
    ManyTeams::GuildExtractionPermission.reset!(guild, country)
    forbidden == plant.many_teams_extractive?
  end
end

puts "\n=== п.7 строительство только в странах игроков"
ManyTeams::PlayerCountry.replace!([own_country.id])
check("строить можно в подтверждённой стране") { ManyTeams::PlayerCountry.buildable?(own_country) }
check("строить нельзя в неподтверждённой стране") { !ManyTeams::PlayerCountry.buildable?(novgorod) }
check("модель Plant отклоняет стройку в чужой стране") do
  template = Plant.where(economic_subject_type: "Guild", economic_subject_id: guild.id).first
  place = PlantPlace.where.not(id: Plant.where(plant_place_id: nil).select(:plant_place_id)).first
  foreign_place = PlantPlace.all.find { |pp| pp.region&.country_id == novgorod.id }
  if template.nil? || foreign_place.nil?
    puts "      нет шаблона предприятия или места в Новгороде — пропущено"
    true
  else
    plant = Plant.new(plant_level: template.plant_level, plant_place: foreign_place,
                      economic_subject: guild)
    invalid = !plant.valid?
    puts "      ошибки: #{plant.errors.full_messages.inspect}" unless invalid == false
    puts "      #{plant.errors[:plant_place].inspect}" if invalid
    invalid
  end
end
check("пустой набор стран игроков снимает ограничение") do
  ManyTeams::PlayerCountry.replace!([])
  ManyTeams::PlayerCountry.buildable?(novgorod)
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

puts "\n=== п.10 «Заморская торговля» снимает все эмбарго"
check("без технологии действие запрещено") do
  tech = Technology.find(Technology::OVERSEAS_TRADE)
  tech.technology_items.where(country_id: own_country.id).update_all(value: 0)
  ManyTeams::GuildEmbargo.impose!(novgorod, guild)
  type = PoliticalActionType.find_by(action: "lift_guild_embargoes")
  action = PoliticalAction.new(political_action_type: type, job: type.job,
                               player: type.job&.council_players(own_country)&.first,
                               country: own_country, year: GameParameter.current_year, success: 1,
                               params: { "guild_id" => guild.id })
  action.save!
  begin
    action.lift_guild_embargoes
    false
  rescue ManyTeams::Error
    true
  end
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
  ManyTeams::GuildEmbargo.where(guild_id: guild.id).count.zero?
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

puts "\n=== итог"
if $fails.empty?
  puts "ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ"
else
  puts "ПРОВАЛЕНО #{ $fails.size }: #{$fails.inspect}"
  exit 1
end
