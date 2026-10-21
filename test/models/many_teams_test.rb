require "test_helper"

# Тесты модели «несколько команд» (ТЗ № 1 «структура данных», § 12).
#
# Покрыты: привязка записей к государству, валидации (игрок без страны, армия с
# незнатным владельцем, самопара отношений, дубль technology_item), разрезы по
# государствам (совет, расходы, результаты, вассалитет) и обратная совместимость
# (при игре за одну страну ведут себя как раньше).
class ManyTeamsTest < ActiveSupport::TestCase
  # Фикстуры репозитория не соответствуют текущей схеме (например,
  # test/fixtures/armies.yml ссылается на колонки region/player/army_size,
  # которых в таблице нет), поэтому тесты создают нужные данные сами.
  self.fixture_table_names = []

  setup do
    # Модели опираются на текущий год игры
    GameParameter.find_or_create_by(identificator: "current_year") do |gp|
      gp.name = "Текущий год"
      gp.value = "1"
    end

    @rus = Country.create!(name: "Тест-Русь-#{SecureRandom.hex(3)}", short_name: "Русь", params: {})
    @litva = Country.create!(name: "Тест-Литва-#{SecureRandom.hex(3)}", short_name: "Литва", params: {})

    @noble_type = PlayerType.find_by(id: PlayerType::NOBLE) ||
                  PlayerType.create!(id: PlayerType::NOBLE, name: "Знать")
    @merchant_type = PlayerType.find_by(id: PlayerType::MERCHANT) ||
                     PlayerType.create!(id: PlayerType::MERCHANT, name: "Купец")

    Country.current = @rus
  end

  teardown do
    Thread.current[:current_country] = nil
    Thread.current[:current_player_id] = nil
  end

  def create_player(name, type, country = nil)
    Player.create!(name: "#{name}-#{SecureRandom.hex(3)}", player_type: type, country: country)
  end

  def create_job(id, name)
    Job.find_by(id: id) || Job.create!(id: id, name: name)
  end

  ############ § 8.2 Игрок и государство ############

  test "игрок без явного государства получает текущее государство" do
    player = Player.create!(name: "Игрок без страны #{SecureRandom.hex(3)}", player_type: @noble_type)

    assert_equal @rus.id, player.country_id
    assert_equal @rus, player.country
  end

  test "явно указанное государство игрока не перетирается значением по умолчанию" do
    player = create_player("Литовский боярин", @noble_type, @litva)

    assert_equal @litva.id, player.country_id
  end

  test "скоупы for_country и nobles фильтруют игроков" do
    rus_noble = create_player("Русский боярин", @noble_type, @rus)
    litva_noble = create_player("Литовский боярин", @noble_type, @litva)
    rus_merchant = create_player("Русский купец", @merchant_type, @rus)

    assert_includes Player.for_country(@rus).to_a, rus_noble
    assert_not_includes Player.for_country(@rus).to_a, litva_noble

    nobles = Player.for_country(@rus).nobles.to_a
    assert_includes nobles, rus_noble
    assert_not_includes nobles, rus_merchant
  end

  ############ § 8.3 Совет государства вместо «игроков должности» ############

  test "совет государства не смешивает держателей должности разных государств" do
    job = create_job(Job::KAZNACHEI, "Казначей")
    rus_treasurer = create_player("Казначей Руси", @noble_type, @rus)
    litva_treasurer = create_player("Казначей Литвы", @noble_type, @litva)
    rus_treasurer.jobs << job
    litva_treasurer.jobs << job

    assert_equal [rus_treasurer.id], @rus.council_player_ids(job)
    assert_equal [litva_treasurer.id], @litva.council_player_ids(job)
    # Должность одна на всех: держателей в базе двое, но совет у каждого свой
    assert_equal 2, job.player_ids.length
    assert_equal [rus_treasurer.id], job.council_player_ids(@rus)
  end

  ############ § 8.11 Гильдия (Д11) ############

  test "гильдия без явного государства получает текущее" do
    guild = Guild.create!(name: "Тест-гильдия без страны #{SecureRandom.hex(3)}", params: {})

    assert_equal @rus.id, guild.country_id

    explicit = Guild.create!(name: "Тест-гильдия Литвы #{SecureRandom.hex(3)}", country: @litva, params: {})
    assert_equal @litva.id, explicit.country_id
  end

  test "Country.resolve принимает и объект, и id (совместимость с Country::RUS)" do
    assert_equal @rus, Country.resolve(@rus)
    assert_equal @rus, Country.resolve(@rus.id)
    assert_nil Country.resolve(nil)
    assert_nil Country.resolve(0)
  end

  ############ § 8.8 Армия ############

  test "армией игрока может владеть только знать своего государства" do
    noble = create_player("Знатный воевода", @noble_type, @rus)
    merchant = create_player("Купец с армией", @merchant_type, @rus)

    noble_army = Army.new(name: "Армия знати #{SecureRandom.hex(3)}", owner: noble)
    assert noble_army.valid?, noble_army.errors.full_messages.inspect
    assert_equal @rus.id, noble_army.country_id

    merchant_army = Army.new(name: "Армия купца #{SecureRandom.hex(3)}", owner: merchant)
    assert_not merchant_army.valid?
    assert merchant_army.errors[:owner].any?
  end

  test "армия государства относит себя к этому государству" do
    army = Army.new(name: "Государева армия #{SecureRandom.hex(3)}", owner: @litva)

    assert army.valid?, army.errors.full_messages.inspect
    army.save!
    assert_equal @litva.id, army.country_id
    assert_includes Army.for_country(@litva).to_a, army
    assert_not_includes Army.for_country(@rus).to_a, army
  end

  ############ § 8.9 Отношения ############

  test "отношения считаются на пару государств и кэпируются" do
    RelationItem.add(1, "тест", @litva, nil, @rus)

    assert_equal 1, @litva.relations(@rus)
    assert_equal 1, @rus.relations_with(@litva)
    # Текущее государство подставляется по умолчанию — прежнее поведение
    assert_equal 1, @litva.relations

    RelationItem.add(10, "тест кэпа", @litva, nil, @rus)
    assert_equal Country::REL_RANGE, @litva.relations_with(@rus)

    # Самопара смысла не имеет
    assert_equal 0, @rus.relations_with(@rus)
  end

  test "самопара отношений запрещена валидацией" do
    item = RelationItem.new(value: 1, comment: "самопара", country: @rus, partner_country: @rus)

    assert_not item.valid?
    assert item.errors[:partner_country_id].any?

    item.partner_country = @litva
    assert item.valid?, item.errors.full_messages.inspect
  end

  ############ § 8.5 Технологии ############

  test "открытие технологии хранится на пару технология-государство" do
    technology = Technology.create!(name: "Тестовая технология #{SecureRandom.hex(3)}")
    TechnologyItem.create!(technology: technology, country: @rus, value: 0)
    TechnologyItem.create!(technology: technology, country: @litva, value: 0)

    assert_equal 0, technology.is_open(@rus)
    technology.open_it(@rus)
    assert_equal 1, technology.is_open(@rus)
    # Открытие одним государством не открывает технологию другому
    assert_equal 0, technology.is_open(@litva)
    technology.close_it(@rus)
    assert_equal 0, technology.is_open(@rus)
  end

  test "дубль technology_item по паре технология-государство запрещён" do
    technology = Technology.create!(name: "Тестовая технология #{SecureRandom.hex(3)}")
    TechnologyItem.create!(technology: technology, country: @rus, value: 0)

    duplicate = TechnologyItem.new(technology: technology, country: @rus, value: 0)
    assert_not duplicate.valid?
    assert duplicate.errors[:technology_id].any?

    another_country = TechnologyItem.new(technology: technology, country: @litva, value: 0)
    assert another_country.valid?, another_country.errors.full_messages.inspect
  end

  ############ § 8.7 Регионы, поселения, общественный порядок ############

  test "регионы и поселения фильтруются по государству" do
    rus_region = Region.create!(name: "Тест-регион Руси #{SecureRandom.hex(3)}", country: @rus)
    litva_region = Region.create!(name: "Тест-регион Литвы #{SecureRandom.hex(3)}", country: @litva)
    rus_settlement = Settlement.create!(name: "Тест-город Руси #{SecureRandom.hex(3)}", region: rus_region)
    litva_settlement = Settlement.create!(name: "Тест-город Литвы #{SecureRandom.hex(3)}", region: litva_region)

    assert_includes Region.for_country(@rus).to_a, rus_region
    assert_not_includes Region.for_country(@rus).to_a, litva_region
    assert_includes Region.foreign_to(@rus).to_a, litva_region

    assert_includes Settlement.for_country(@rus).to_a, rus_settlement
    assert_not_includes Settlement.for_country(@rus).to_a, litva_settlement
    assert_equal @litva.id, litva_settlement.country_id
  end

  test "правка общественного порядка без региона применяется к регионам своего государства" do
    rus_region = Region.create!(name: "Тест-регион Руси #{SecureRandom.hex(3)}", country: @rus)
    litva_region = Region.create!(name: "Тест-регион Литвы #{SecureRandom.hex(3)}", country: @litva)

    PublicOrderItem.add(-1, "тест без региона", nil, nil, @rus)

    assert_equal(-1, rus_region.reload.public_order_items.sum(&:value))
    assert_equal 0, litva_region.reload.public_order_items.sum(&:value)
  end

  ############ § 13 (Д12) Расходы государства ############

  test "оплата госрасходов независима у каждого государства и хранится по годам" do
    year = 5

    assert_not @rus.state_expenses_paid?(year)
    assert_not @litva.state_expenses_paid?(year)

    @rus.pay_state_expenses(year)
    assert @rus.state_expenses_paid?(year)
    assert_not @litva.state_expenses_paid?(year)
    assert_not @rus.state_expenses_paid?(year + 1)

    @litva.unpay_state_expenses(year)
    assert_not @litva.state_expenses_paid?(year)
    assert @rus.state_expenses_paid?(year)
  end

  ############ § 14 (Д13) Годовые результаты ############

  test "ранжирование знати считается в разрезе государства" do
    rus_noble = create_player("Русский боярин", @noble_type, @rus)
    litva_noble = create_player("Литовский боярин", @noble_type, @litva)
    InfluenceItem.add(7, "тест влияния", rus_noble)
    InfluenceItem.add(3, "тест влияния", litva_noble)

    rus_names = GameParameter.show_noble_results(@rus).map { |row| row[:noble_name] }
    assert_includes rus_names, rus_noble.name
    assert_not_includes rus_names, litva_noble.name

    assert_equal 7, GameParameter.show_noble_results(@rus).first[:noble_influence]
    assert_equal 3, GameParameter.show_noble_results(@litva).first[:noble_influence]
  end

  test "ранжирование купцов считает только гильдии государства" do
    rus_guild = Guild.create!(name: "Тест-гильдия Руси #{SecureRandom.hex(3)}", country: @rus, params: {})
    litva_guild = Guild.create!(name: "Тест-гильдия Литвы #{SecureRandom.hex(3)}", country: @litva, params: {})

    rus_ids = GameParameter.show_sorted_results(country: @rus).map { |row| row[:guild_id] }
    litva_ids = GameParameter.show_sorted_results(country: @litva).map { |row| row[:guild_id] }

    assert_includes rus_ids, rus_guild.id
    assert_not_includes rus_ids, litva_guild.id
    assert_includes litva_ids, litva_guild.id
    assert_not_includes litva_ids, rus_guild.id
  end

  test "снимок годовых результатов хранится по году и государству" do
    noble = create_player("Русский боярин", @noble_type, @rus)
    Guild.create!(name: "Тест-гильдия Руси #{SecureRandom.hex(3)}", country: @rus, params: {})

    snapshot = GameParameter.snapshot_year_results(9)
    assert snapshot.key?(@rus.id.to_s)

    # Снимок лежит в params записи results и читается по паре «год × государство»
    # (значения проходят через JSON, поэтому ключи строковые)
    stored = GameParameter.results_for_year(9, @rus)
    assert_equal 1, stored["nobles"].length
    assert_equal noble.name, stored["nobles"].first["noble_name"]
    assert stored["merchants"].is_a?(Array)
    # У другого государства свой срез
    assert GameParameter.results_for_year(9, @litva).present?

    # Пустой срез дописывается, заполненный — не перетирается без force
    GameParameter.snapshot_year_results(9)
    assert_equal stored["closed_at"], GameParameter.results_for_year(9, @rus)["closed_at"]
  end

  ############ § 15 (Д14) Вассалитет ############

  test "флаг вассалитета хранится по паре сюзерен-вассал" do
    checklist = VassalsAndRobbers::Checklist.create!(
      vassal_country: @litva,
      sovereign_country: @rus,
      conditions: { "conditions" => [] },
      params: {}
    )

    assert_not checklist.established?(@rus)
    checklist.set_established(true, @rus)
    assert checklist.established?(@rus)

    assert_includes VassalsAndRobbers::Checklist.for_sovereign(@rus).to_a, checklist
    assert_not_includes VassalsAndRobbers::Checklist.for_sovereign(@litva).to_a, checklist
    assert_includes VassalsAndRobbers::Checklist.vassal_country_ids(@rus), @litva.id
    assert_empty VassalsAndRobbers::Checklist.vassal_country_ids(@litva)
  end

  test "одно государство не может быть вассалом двух сюзеренов с одинаковым сюзереном дважды" do
    tver = Country.create!(name: "Тест-Тверь #{SecureRandom.hex(3)}", short_name: "Тверь", params: {})
    VassalsAndRobbers::Checklist.create!(
      vassal_country: @litva, sovereign_country: @rus,
      conditions: { "conditions" => [] }, params: {}
    )

    duplicate = VassalsAndRobbers::Checklist.new(
      vassal_country: @litva, sovereign_country: @rus,
      conditions: { "conditions" => [] }, params: {}
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:vassal_country_id].any?

    # Другой сюзерен — отдельная пара, конфликта нет
    another = VassalsAndRobbers::Checklist.new(
      vassal_country: @litva, sovereign_country: tver,
      conditions: { "conditions" => [] }, params: {}
    )
    assert another.valid?, another.errors.full_messages.inspect
  end

  test "легаси-ключ вассалитета читается как пара с Русью" do
    # Легаси-ключ относится именно к «Руси» (id = Country::RUS), поэтому создаём её
    rus = Country.find_by(id: Country::RUS) ||
          Country.create!(id: Country::RUS, name: "Тест-Русь (id 1)", short_name: "Русь", params: {})
    checklist = VassalsAndRobbers::Checklist.create!(
      vassal_country: @litva,
      sovereign_country: nil, # записи до перехода: сюзерен не заполнен
      conditions: { "conditions" => [] },
      params: { "vassal_#{@litva.id}_established" => true }
    )

    assert_equal rus, checklist.sovereign
    assert checklist.established?(rus)
    # Для другого сюзерена легаси-ключ ничего не значит
    assert_not checklist.established?(@rus)
  end

  ############ § 13 п. 5 Статистика расходов по государствам ############

  test "статистика госрасходов разбирается по государствам" do
    controller = AuditsController.new
    audits = [
      fake_country_audit(@rus, { "1" => true }, { "1" => false }),
      fake_country_audit(@litva, { "1" => false }, { "1" => true })
    ]

    stats = controller.send(:get_state_expenses_stats, audits)

    assert_includes stats[:by_country].keys, @rus.id.to_s
    assert_includes stats[:by_country].keys, @litva.id.to_s
    assert_equal "paid", stats[:by_country][@litva.id.to_s][:final_state]
    assert_equal "unpaid", stats[:by_country][@rus.id.to_s][:final_state]
  end

  private

  # Минимальный двойник аудита: важно только, что страна и diff params читаются
  def fake_country_audit(country, old_expenses, new_expenses)
    Struct.new(:auditable_type, :auditable_id, :action, :audited_changes, :created_at, :year)
          .new("Country", country.id, "update",
               { "params" => [{ "state_expenses" => old_expenses }, { "state_expenses" => new_expenses }] },
               Time.current, GameParameter.current_year)
  end
end
