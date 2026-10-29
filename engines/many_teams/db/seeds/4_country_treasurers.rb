# Казначей в каждом государстве (many_teams, запрос заказчика).
#
# Зачем: владение (поселение) передаётся только знатному игроку, а у государств,
# за которые никто не играет, знати не было вовсе — передавать владения было
# некому. Сид даёт каждому государству одного знатного игрока на должности
# «Казначей». Имя игрока — КОРОТКОЕ название государства (`countries.short_name`:
# Орда, Ливония, Швеция, Литва, Казань, Крым, Пермь, Вятка, Рязань, Тверь,
# Новгород, Москва), чтобы в списках выбора владельца страна читалась по имени.
#
# Государства, где казначей уже есть, пропускаются: у «Москвы» казначей приходит
# из сидов ядра (`db/seeds/1_players.rb`), у «Новгорода» — из состава совета
# (`1_novgorod_nobles_and_cities.rb`). Второй казначей в государстве дал бы
# двойной бонус за оплату госрасходов (`Job::KAZNACHEI_BONUS`) и двойной доход
# от вассалов, поэтому дубликатов не создаём.
#
# Сид идемпотентен: игрок ищется по идентификатору, повторный прогон печатает
# «уже есть».
puts "[many_teams] казначеи государств"

noble_type = PlayerType.find_by(name: "Знать")
treasurer_job = Job.find_by(id: Job::KAZNACHEI)

if noble_type.nil? || treasurer_job.nil?
  puts "  ! нет типа игрока «Знать» или должности «Казначей» — сид пропущен"
else
  created = []
  skipped = []

  Country.order(:id).each do |country|
    if country.council_players(Job::KAZNACHEI).exists?
      skipped << "#{country.short_name.presence || country.name} (уже есть)"
      next
    end

    name = country.short_name.presence || country.name
    identificator = Player.generate_identificator(name, nil, nil, treasurer_job.name, "MANY_TEAMS_COUNTRY_#{country.id}")

    player = Player.find_or_initialize_by(identificator: identificator)
    player.name = name
    player.player_type = noble_type
    player.family = Family.find_or_create_by(name: name)
    player.country_id = country.id
    player.jobs = [treasurer_job]
    player.params = (player.params || {}).merge("income_taken" => false)
    player.save!
    InfluenceItem.add(0, "Ручная правка", player) if player.influence_items.empty?

    created << "#{country.name} → «#{player.name}»"
  end

  puts "  созданы: #{created.empty? ? 'нет' : created.join(', ')}"
  puts "  пропущены: #{skipped.empty? ? 'нет' : skipped.join(', ')}"

  treasurers = Player.joins(:jobs).where(jobs: { id: Job::KAZNACHEI }).distinct
  missing = Country.order(:id).reject { |c| c.council_players(Job::KAZNACHEI).exists? }
  puts "  казначеев в государствах: #{treasurers.size}; государств: #{Country.count}"
  puts "  ! без казначея: #{missing.map(&:name).join(', ')}" if missing.any?
end
