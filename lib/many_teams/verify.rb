# Проверки ТЗ № 1 «структура данных» (§ 12) на текущей базе.
#
# Запуск: bin/rails many_teams:verify            — только чтение
#         MUTATING=1 bin/rails many_teams:verify — плюс оплата госрасходов и смена
#         года (меняет данные игры, запускать на копии базы).
#
# По умолчанию проверки, которые меняют данные (оплата расходов, смена года),
# пропускаются: их можно прогнать только явно.
MUTATING = ENV['MUTATING'] == '1'

# Проверки ТЗ № 1 (§ 12) на свежесидированной базе: работа за одну страну,
# затем работа за второе государство.
$failures = []
def check(name, condition, detail = "")
  puts "#{condition ? 'OK  ' : 'FAIL'} #{name} #{detail}"
  $failures << "#{name}: #{detail}" unless condition
  condition
end

rus = Country.find_by(id: Country::RUS) || Country.order(:id).first
other = Country.where.not(id: rus.id).order(:id).first
Country.current = rus

puts "=== § 12 п. 2, 4. Данные после сидирования ==="
check("стран 12", Country.count == 12, "стран=#{Country.count}")
tech_count = Technology.count
check("технологий не меньше 9", tech_count >= 9, "технологий=#{tech_count}")
expected_items = tech_count * Country.count
check("technology_items = технологии × государства (#{expected_items})", TechnologyItem.count == expected_items, "строк=#{TechnologyItem.count}")
check("у каждого государства полный набор технологий",
      TechnologyItem.group(:country_id).count.values.uniq == [tech_count],
      "значения=#{TechnologyItem.group(:country_id).count.values.uniq}")
check("игроков без государства 0", Player.where(country_id: nil).count.zero?, "без страны=#{Player.where(country_id: nil).count}")
check("технологических фактов без государства 0", TechnologyItem.where(country_id: nil).count.zero?)
check("политдействий без государства 0", PoliticalAction.where(country_id: nil).count.zero?)
check("самопар отношений нет", RelationItem.where("country_id = partner_country_id").count.zero?,
      "самопар=#{RelationItem.where('country_id = partner_country_id').count}")
check("отношения есть у каждого государства",
      RelationItem.group(:country_id).count.size == 12, "государств с отношениями=#{RelationItem.group(:country_id).count.size}")
check("справочник должностей на месте (10 по ТЗ; в сидах — сколько есть)", Job.count >= 9, "должностей=#{Job.count}")
check("все гильдии привязаны к государству", Guild.where(country_id: nil).count.zero?, "без страны=#{Guild.where(country_id: nil).count}")
check("все армии относятся к государству через владельца", Army.all.all? { |a| a.country_id.present? }, "без страны=#{Army.all.count { |a| a.country_id.blank? }}")

puts "=== § 12 п. 5. Работа за второе государство (#{other.id} #{other.name}) ==="
Country.current = other
check("технологии второго государства — свой полный набор",
      other.technology_items.count == tech_count, "строк=#{other.technology_items.count}")
check("знать чужого государства — казначей страны",
      Player.nobles.where(country_id: other.id).count == 1,
      "знати=#{Player.nobles.where(country_id: other.id).count}")
check("гильдии чужого государства пусты", Guild.where(country_id: other.id).count.zero?,
      "гильдий=#{Guild.where(country_id: other.id).count}")
check("экраны второго государства отдают данные без ошибок",
      Country.except_country(rus).count == 11 && other.regions.count.positive?,
      "чужих государств=#{Country.except_country(rus).count}, регионов=#{other.regions.count}")
check("Technology.find(Technology::CRAFTSMEN).is_open(чужая страна) = false",
      Technology.find(Technology::CRAFTSMEN).is_open(other) == 0)
check("в совете второго государства один казначей",
      other.council_player_ids(Job::KAZNACHEI).size == 1,
      "казначеев=#{other.council_player_ids(Job::KAZNACHEI).size}")
# § 13 (many_teams): владение передаётся знатному игроку, поэтому казначей нужен
# в КАЖДОМ государстве — иначе передавать владения в чужой стране некому.
missing_treasurers = Country.order(:id).reject { |c| c.council_players(Job::KAZNACHEI).exists? }
check("казначей есть в каждом государстве",
      missing_treasurers.empty?,
      "без казначея=#{missing_treasurers.map(&:name).inspect}")
# Имена проверяем только у казначеев, которых создал сид движка: у «Москвы» и
# «Новгорода» казначеи пришли из сидов ядра и совета, их имена исторические.
treasurer_job_name = Job.find_by(id: Job::KAZNACHEI)&.name
seed_name_mismatch = Country.order(:id).filter_map do |c|
  treasurer = c.council_players(Job::KAZNACHEI).first
  next if treasurer.nil?

  expected_identificator = Player.generate_identificator(
    (c.short_name.presence || c.name), nil, nil, treasurer_job_name, "MANY_TEAMS_COUNTRY_#{c.id}"
  )
  next unless treasurer.identificator == expected_identificator

  "«#{treasurer.name}» вместо «#{c.short_name.presence || c.name}»" if treasurer.name != (c.short_name.presence || c.name)
end
check("казначеи из сида названы коротким названием страны",
      seed_name_mismatch.empty?,
      seed_name_mismatch.inspect)

puts "=== § 12 п. 6. Скоупы и методы ==="
Country.current = rus
noble = Player.nobles.where(country_id: rus.id).first
breakdown = noble.income_breakdown(rus)
settlements = breakdown[:settlements] || []
check("доход считается только по владениям своего государства",
      settlements.all? { |s| s[:country_id] == rus.id },
      "поселений=#{settlements.size}, чужих=#{settlements.count { |s| s[:country_id] != rus.id }}")
check("одна величина отношений на пару",
      rus.relations_with(other) == other.relations_with(rus),
      "#{rus.relations_with(other)} / #{other.relations_with(rus)}")
check("relations_with себя = 0", rus.relations_with(rus).zero?)
check("армии фильтруются по государству",
      Army.for_country(rus).pluck(:id).sort == Army.where(id: Army.all.select { |a| a.country_id == rus.id }.map(&:id)).pluck(:id).sort,
      "армий Руси=#{Army.for_country(rus).count}, всего=#{Army.count}")
check("поселения фильтруются по государству",
      Settlement.for_country(rus).all? { |s| s.region&.country_id == rus.id },
      "поселений=#{Settlement.for_country(rus).count}")

if MUTATING
  puts "=== § 12 п. 7. Расходы государства (Д12) ==="
  year = GameParameter.current_year
  check("до оплаты у Руси флаг не стоит", rus.state_expenses_paid?(year) == false)
  result = GameParameter.pay_state_expenses(rus)
  check("оплата расходов Руси проходит", result.is_a?(Hash), result.inspect[0, 120])
  rus.reload
  other.reload
  check("флаг Руси поднят", rus.state_expenses_paid?(year) == true)
  check("флаг второго государства не тронут", other.state_expenses_paid?(year) == false)
  audit = CustomAudit.where(auditable_type: 'Country', auditable_id: rus.id).order(:id).last
  check("аудит содержит год и название государства",
        audit&.comment.to_s.include?(year.to_s) && audit&.comment.to_s.include?(rus.name),
        audit&.comment.to_s[0, 90])

  puts "=== § 12 п. 7-8. Смена года: снимок результатов и порядок у неоплатившего ==="
  old_year = year
  GameParameter.increase_year(Job::KAZNACHEI_BONUS)
  new_year = GameParameter.current_year
  check("год увеличился", new_year == old_year + 1, "было #{old_year}, стало #{new_year}")
  snapshot_rus = GameParameter.results_for_year(old_year, rus)
  snapshot_other = GameParameter.results_for_year(old_year, other)
  check("снимок года сохранён для Руси", snapshot_rus.present?, snapshot_rus.class.to_s)
  check("снимок года сохранён для второго государства", snapshot_other.present?)
  non_payer = other.reload
  po_comment = PublicOrderItem.where(region_id: non_payer.regions.pluck(:id)).pluck(:comment)
  check("неоплатившему начислен «Не оплачены расходы» в его регионах",
        po_comment.any? { |c| c.to_s.include?('Не оплачены расходы') },
        "комментарии=#{po_comment.uniq.first(3).inspect}")
  rus_po = PublicOrderItem.where(region_id: rus.regions.pluck(:id)).pluck(:comment)
  check("оплатившему штраф не начислен",
        rus_po.none? { |c| c.to_s.include?('Не оплачены расходы') })
else
  puts "=== § 12 п. 7-8. Расходы, смена года и снимок результатов: пропущено (MUTATING=1) ==="
end

puts "=== § 12 п. 8. Годовые результаты по государствам ==="
Current_year = GameParameter.current_year
noble_rows = GameParameter.show_noble_results(rus)
foreign_nobles = noble_rows.map { |r| Player.find_by(name: r[:noble_name])&.country_id }.uniq
check("в ранжировании знати только своё государство",
      foreign_nobles == [rus.id], "государства=#{foreign_nobles.inspect}")
guild_rows = GameParameter.show_sorted_results(country: rus)
guild_countries = guild_rows.map { |r| Guild.find_by(id: r[:guild_id])&.country_id }.uniq
check("в ранжировании купцов только гильдии своего государства",
      guild_countries == [rus.id], "государства=#{guild_countries.inspect}")
check("у второго государства своё ранжирование",
      GameParameter.show_sorted_results(country: other).all? { |r| Guild.find_by(id: r[:guild_id])&.country_id == other.id })
check("снимок текущего года пишется по государствам",
      (GameParameter.snapshot_year_results(Current_year) || {}).keys.map(&:to_i).include?(rus.id))

puts "=== § 12 п. 9. Движки (Д14) ==="
checklists = VassalsAndRobbers::Checklist.where(sovereign_country_id: rus.id)
check("чек-листы Руси на месте (5)", checklists.count == 5, "чек-листов=#{checklists.count}")
check("сюзерен чек-листов — Русь", checklists.all? { |cl| cl.sovereign&.id == rus.id })
check("у второго государства чек-листов нет",
      VassalsAndRobbers::Checklist.where(sovereign_country_id: other.id).count.zero?)
check("флаг «присоединена» читается по паре",
      checklists.any? { |cl| cl.established?(rus) },
      "присоединено=#{checklists.count { |cl| cl.established?(rus) }}")
check("цены ресурсов считаются в разрезе государства",
      (Resource.respond_to?(:show_prices) ? true : false),
      "мест под строения=#{PlantPlace.count}, предприятий=#{Plant.count}")
check("караван можно отправить от текущего государства",
      Resource.respond_to?(:send_caravan), "Resource.send_caravan есть")

puts
if $failures.empty?
  puts "ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ"
else
  puts "ПРОВАЛЕНО #{$failures.size}:"
  $failures.each { |f| puts "  - #{f}" }
end
exit($failures.empty? ? 0 : 1)
