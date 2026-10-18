require "test_helper"

# Тесты этапа 2 «функциональность» (ТЗ № 2): разделение данных по государствам на
# уровне API. Проверяются места, где раньше «одно государство» было зашито жёстко:
# матрица отношений Дашборда, смена текущего государства, держатели должностей,
# фильтр игроков, расходы государства, настройки вассалитета.
#
# Тесты самодостаточны: фикстуры репозитория не соответствуют схеме
# (см. test/models/many_teams_test.rb), поэтому данные создаются в setup.
class ManyTeamsTz2Test < ActionDispatch::IntegrationTest
  self.fixture_table_names = []

  setup do
    GameParameter.find_or_create_by(identificator: "current_year") do |gp|
      gp.name = "Текущий год"
      gp.value = "1"
      gp.params = {}
    end

    @rus = Country.find_or_create_by(id: Country::RUS) do |c|
      c.name = "Тест-Русь"
      c.short_name = "Русь"
      c.params = {}
    end
    @litva = Country.find_or_create_by(id: 5) do |c|
      c.name = "Тест-Литва"
      c.short_name = "Литва"
      c.params = {}
    end
    @novgorod = Country.find_or_create_by(id: 3) do |c|
      c.name = "Тест-Новгород"
      c.short_name = "Новгород"
      c.params = {}
    end

    @noble_type = PlayerType.find_by(id: PlayerType::NOBLE) ||
                  PlayerType.create!(id: PlayerType::NOBLE, name: "Знать")
    @merchant_type = PlayerType.find_by(id: PlayerType::MERCHANT) ||
                     PlayerType.create!(id: PlayerType::MERCHANT, name: "Купец")

    # Код читает технологии по константам (Technology.find / Technology#is_open),
    # в пустой тестовой базе их нужно создать — как это делают сиды
    ensure_technologies

    Country.current = @rus
  end

  # Технологии, на которые ссылается код: «Юрьев день» (доход), «Помазанник божий»
  # (общественный порядок региона), «Москва — Третий Рим» (бонус пары отношений)
  def ensure_technologies
    {
      Technology::ST_GEORGE_DAY => "Юрьев день",
      Technology::GODS_ANOITED => "Помазанник божий",
      Technology::MOSCOW_THIRD_ROME => "Москва — Третий Рим",
    }.each do |id, name|
      Technology.find_by(id: id) || Technology.create!(id: id, name: name, description: name)
    end
  end

  teardown do
    Thread.current[:current_country] = nil
  end

  def create_player(name, type, country)
    Player.create!(name: "#{name}-#{SecureRandom.hex(3)}", player_type: type, country: country)
  end

  ############ § 2.3 Матрица отношений Дашборда ############

  test "relations_matrix отдаёт пары выбранных государств со всеми остальными" do
    get "/countries/relations_matrix.json", params: { country_ids: "#{@rus.id},#{@litva.id}" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal [@rus.id, @litva.id].sort, payload["country_ids"].sort
    assert_equal 2, payload["countries"].length

    # 2 выбранных × (всего стран − 2 выбранных); в тестовой базе ровно 3 страны
    assert_equal 2, payload["rows"].length
    rows = payload["rows"]

    # Пары между выбранными не показываются, самопары отсутствуют, дублей нет
    rows.each do |row|
      refute_equal row["partner"]["id"], row["country"]["id"]
    end

    pairs = rows.map { |row| [row["partner"]["id"], row["country"]["id"]] }
    assert_equal pairs.length, pairs.uniq.length
    pairs.each do |a, b|
      refute_includes [@rus.id, @litva.id], b if [@rus.id, @litva.id].include?(a)
    end

    # Строка отдаёт данные пары: значение отношений, торговые очки, правки
    row = rows.first
    assert row.key?("country")
    assert row["country"].key?("relations")
    assert row["country"].key?("relation_points")
    assert row["country"].key?("relation_items")
    assert_equal row["partner"]["id"], row["country"]["relation_partner_id"]
  end

  test "значение пары совпадает с /countries.json для той же пары" do
    RelationItem.create!(country: @litva, value: 1, comment: "тест", partner_country: @rus)

    get "/countries/relations_matrix.json", params: { country_ids: @rus.id.to_s }
    matrix_row = JSON.parse(response.body)["rows"].find { |r| r["country"]["id"] == @litva.id }
    assert_equal 1, matrix_row["country"]["relations"]

    # Та же пара в разрезе Литвы (государство A = Литва) — значение симметрично
    get "/countries/relations_matrix.json", params: { country_ids: @litva.id.to_s }
    litva_row = JSON.parse(response.body)["rows"].find { |r| r["country"]["id"] == @rus.id }
    assert_equal 1, litva_row["country"]["relations"]
  end

  test "relations_matrix без параметров берёт текущее государство" do
    get "/countries/relations_matrix.json"

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal [@rus.id], payload["country_ids"]
  end

  ############ § 1.1 Текущее государство ############

  test "login_country несуществующим государством не ломает сессию" do
    get "/login_country/#{@litva.id}.json"
    assert_response :success

    get "/login_country/999999.json"
    assert_response :not_found

    get "/current_country.json"
    assert_response :success
    assert_equal @litva.id, JSON.parse(response.body)["id"]
  end

  ############ § 5 Смена держателя должности в пределах государства ############

  test "смена держателя должности в одном государстве не стирает держателей другого" do
    job = Job.find_by(id: Job::GRAND_PRINCE) || Job.create!(id: Job::GRAND_PRINCE, name: "Великий князь")
    rus_noble = create_player("Русский боярин", @noble_type, @rus)
    litva_noble = create_player("Литовский боярин", @noble_type, @litva)

    job.update!(player_ids: [rus_noble.id])

    patch "/jobs/#{job.id}.json",
          params: { country_id: @litva.id, job: { player_ids: [litva_noble.id] } }

    assert_response :success
    job.reload
    assert_includes job.player_ids, rus_noble.id
    assert_includes job.player_ids, litva_noble.id

    # Совет каждого государства отдаётся отдельно
    assert_equal [rus_noble.id], @rus.council_player_ids(Job::GRAND_PRINCE)
    assert_equal [litva_noble.id], @litva.council_player_ids(Job::GRAND_PRINCE)
  end

  test "держатели должности читаются в разрезе государства" do
    job = Job.find_by(id: Job::KAZNACHEI) || Job.create!(id: Job::KAZNACHEI, name: "Казначей")
    rus_treasurer = create_player("Казначей Руси", @noble_type, @rus)
    litva_treasurer = create_player("Казначей Литвы", @noble_type, @litva)
    job.update!(player_ids: [rus_treasurer.id, litva_treasurer.id])

    get "/jobs.json", params: { nobles: 1, country_id: @litva.id }
    assert_response :success
    treasurer = JSON.parse(response.body).find { |j| j["id"] == Job::KAZNACHEI }
    assert_equal [litva_treasurer.id], treasurer["player_ids"]
    assert_equal @litva.id, treasurer["country_id"]
  end

  ############ § 1.3 Игроки привязаны к государству ############

  test "players.json с country_id отдаёт только игроков этого государства" do
    create_player("Русский", @noble_type, @rus)
    create_player("Литовский", @noble_type, @litva)

    get "/players.json", params: { country_id: @litva.id }
    assert_response :success
    names = JSON.parse(response.body).map { |p| p["country_id"] }.uniq
    assert_equal [@litva.id], names
  end

  test "игрок создаётся с выбранным государством" do
    name = "Новый литовец #{SecureRandom.hex(3)}"
    post "/players.json", params: { player: { name: name,
                                              player_type_id: @noble_type.id,
                                              country_id: @litva.id } }

    assert_response :success
    created = Player.find_by(name: name)
    assert_not_nil created
    assert_equal @litva.id, created.country_id
  end

  ############ § 8 Расходы государства ############

  test "подтверждение расходов одного государства не подтверждает их у другого" do
    patch "/game_parameters/pay_state_expenses.json", params: { country_id: @rus.id }
    assert_response :success

    assert @rus.reload.state_expenses_paid?
    refute @litva.reload.state_expenses_paid?

    patch "/game_parameters/unpay_state_expenses.json", params: { country_id: @rus.id }
    assert_response :success
    refute @rus.reload.state_expenses_paid?
  end

  ############ § 7.2 Настройки вассальных доходов по сюзеренам ############

  test "суммы вассальных доходов пишутся и читаются по государству" do
    patch "/game_parameters/update_vassalage_settings.json",
          params: { country_id: @rus.id, vassal_incomes: { @litva.id.to_s => 30000 } }
    assert_response :success

    patch "/game_parameters/update_vassalage_settings.json",
          params: { country_id: @novgorod.id, vassal_incomes: { @litva.id.to_s => 1000 } }
    assert_response :success

    get "/game_parameters/get_vassalage_settings.json", params: { country_id: @rus.id }
    rus_settings = JSON.parse(response.body)
    assert_equal "30000", rus_settings["vassal_incomes"][@litva.id.to_s].to_s

    get "/game_parameters/get_vassalage_settings.json", params: { country_id: @novgorod.id }
    novgorod_settings = JSON.parse(response.body)
    assert_equal "1000", novgorod_settings["vassal_incomes"][@litva.id.to_s].to_s

    # Настройки «Руси» не перетёрлись настройками Новгорода
    assert_equal "30000", rus_settings["by_sovereign"][@rus.id.to_s][@litva.id.to_s].to_s
  end

  ############ § 7.3 Гильдии: государство гильдии в ответе ############

  test "список гильдий отдаёт государство гильдии" do
    guild = Guild.create!(name: "Гильдия Литвы", country: @litva)

    get "/guilds/list.json"

    assert_response :success
    entry = JSON.parse(response.body).find { |item| item["id"] == guild.id }
    assert_not_nil entry, "гильдия созданного государства не попала в список"
    assert_equal @litva.id, entry["country_id"]
    assert_equal @litva.name, entry["country"]["name"]
  ensure
    guild&.destroy
  end

  ############ § 7.1 Чек-листы вассалитета считаются по сюзерену ############

  test "чек-листы вассалитета отдаются государству-сюзерену и считают условия" do
    checklist = VassalsAndRobbers::Checklist.create!(
      vassal_country: @litva,
      sovereign_country_id: @rus.id,
      # Условия хранятся вложенным ключом «conditions» — как в сидах движка
      conditions: {
        "conditions" => [
          { "type" => "trade_turnover", "target_country_id" => @litva.id, "requirement" => 1,
            "description" => "Уровень товарооборота с Литвой" },
          { "type" => "relations", "target_country_id" => @litva.id, "requirement" => 1,
            "description" => "Отношения с Литвой" },
        ],
      },
    )

    get "/vassals_and_robbers/checklists.json", params: { country_id: @rus.id }

    assert_response :success
    entry = JSON.parse(response.body).find { |item| item["id"] == checklist.id }
    assert_not_nil entry, "чек-лист не отдан своему сюзерену"
    assert_equal @rus.id, entry["sovereign_country_id"]
    assert_equal @litva.id, entry["vassal_country"]["id"]
    assert_equal 2, entry["total_count"]
    assert_equal entry["total_count"], entry["conditions"].length
    assert entry["conditions"].all? { |condition| condition.key?("is_completed") }
  end

  test "условие товарооборота считается по паре государств, а не падает" do
    # Раньше show_current_trade_level вызывался с сюзереном, но не принимал аргумент:
    # эндпоинт чек-листов отвечал 500 вместо списка (регресс § 7.1)
    level = @litva.show_current_trade_level(@rus)
    assert_kind_of Hash, level
    assert level.key?(:current_level)
    assert level.key?(:to_next_level)

    # Без аргумента работает как прежде — по текущему государству
    assert_kind_of Hash, @litva.show_current_trade_level
  end

  ############ § 9 Годовые результаты по государству ############

  test "screen_bundle отдаёт результаты запрошенного государства" do
    create_player("Русский боярин", @noble_type, @rus)
    create_player("Литовский боярин", @noble_type, @litva)

    get "/game_parameters/screen_bundle", params: { country_id: @litva.id }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal @litva.id, payload["country_id"]
    assert_equal "live", payload["source"]
    rus_names = @rus.players.pluck(:name)
    noble_names = (payload["nobles"] || []).map { |n| n["noble_name"] }
    assert_empty(noble_names & rus_names)
  end
end
