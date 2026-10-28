require "test_helper"

# Тесты табло «Результаты всех команд» (`ManyTeams::AllTeamsResults`):
# экономика считается по землям государства, политика — сумма влияния игроков
# государства, личный зачёт ранжируется по всем командам сразу. Проверяется и
# совпадение с существующими расчётами ядра, чтобы табло не разошлось с экранами
# результатов.
class ManyTeamsAllTeamsResultsTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    GameParameter.find_or_create_by(identificator: "current_year") do |gp|
      gp.name = "Текущий год"
      gp.value = "3"
    end

    @noble_type = PlayerType.find_by(id: PlayerType::NOBLE) ||
                  PlayerType.create!(id: PlayerType::NOBLE, name: "Знать")
    @merchant_type = PlayerType.find_by(id: PlayerType::MERCHANT) ||
                     PlayerType.create!(id: PlayerType::MERCHANT, name: "Купец")

    @rus = create_country("Москва")
    @novgorod = create_country("Великий Новгород")
  end

  teardown do
    Thread.current[:current_country] = nil
    Thread.current[:current_player_id] = nil
  end

  def create_country(name)
    Country.create!(name: "#{name}-#{SecureRandom.hex(3)}", short_name: name, params: {})
  end

  def create_player(name, type, country)
    Player.create!(name: "#{name}-#{SecureRandom.hex(3)}", player_type: type, country: country)
  end

  def create_place(country, name)
    region = Region.create!(name: "#{name}-reg-#{SecureRandom.hex(3)}", country: country)
    category = PlantCategory.find_by(name: "Добывающее") ||
               PlantCategory.create!(name: "Добывающее", is_extractive: true)
    PlantPlace.create!(name: "#{name}-place-#{SecureRandom.hex(3)}", region: region, plant_category: category)
  end

  def create_plant(guild, place, deposit)
    category = PlantCategory.find_by(name: "Добывающее") ||
               PlantCategory.create!(name: "Добывающее", is_extractive: true)
    type = PlantType.create!(name: "Тип-#{SecureRandom.hex(3)}", plant_category: category)
    level = PlantLevel.create!(level: 1, deposit: deposit, price: {}, formulas: [], plant_type: type)
    Plant.create!(plant_level: level, plant_place: place, economic_subject: guild)
  end

  def add_influence(player, value)
    InfluenceItem.add(value, "тест", player)
  end

  def rows_by_country(data)
    data[:countries].index_by { |row| row[:country_id] }
  end

  test "экономика считается по землям государства, а не по государству владельца" do
    create_player("Новгородский боярин", @noble_type, @novgorod)
    create_player("Московский боярин", @noble_type, @rus)
    guild = Guild.create!(name: "Гильдия-#{SecureRandom.hex(3)}", country: @rus)

    create_plant(guild, create_place(@novgorod, "новая"), 1000)
    create_plant(guild, create_place(@rus, "московская"), 500)

    rows = rows_by_country(ManyTeams::AllTeamsResults.new.as_json)

    assert_equal 1000, rows[@novgorod.id][:economy][:value]
    assert_equal 1, rows[@novgorod.id][:economy][:plants_count]
    assert_equal 500, rows[@rus.id][:economy][:value]
    assert_equal 1, rows[@rus.id][:economy][:plants_count]
  end

  test "политика — сумма влияния игроков государства" do
    noble = create_player("Боярин", @noble_type, @rus)
    other = create_player("Второй боярин", @noble_type, @rus)
    create_player("Новгородец", @noble_type, @novgorod)

    add_influence(noble, 3)
    add_influence(other, 2)

    rows = rows_by_country(ManyTeams::AllTeamsResults.new.as_json)

    assert_equal 5, rows[@rus.id][:politics][:value]
    assert_equal 0, rows[@novgorod.id][:politics][:value]
    assert_equal noble.influence(@rus), 3
    assert_equal rows[@rus.id][:politics][:value],
                 Player.where(country_id: @rus.id).sum { |player| player.influence(@rus) }
  end

  test "места по экономике и политике считаются отдельно, сводного места нет" do
    create_player("Купчик", @merchant_type, @rus)
    nov_noble = create_player("Новгородец", @noble_type, @novgorod)
    add_influence(nov_noble, 3)

    rich = Guild.create!(name: "Богатая-#{SecureRandom.hex(3)}", country: @novgorod)
    create_plant(rich, create_place(@novgorod, "богатая"), 5000)

    data = ManyTeams::AllTeamsResults.new.as_json
    rows = rows_by_country(data)

    assert_equal 1, rows[@novgorod.id][:economy][:place]
    assert_equal 2, rows[@rus.id][:economy][:place]
    assert_equal 1, rows[@novgorod.id][:politics][:place]
    assert_equal 2, rows[@rus.id][:politics][:place]
    assert_not data[:countries].first.key?(:place), "сводного места у команды быть не должно"
  end

  test "в зачёт входят только государства, за которые играют" do
    create_player("Боярин", @noble_type, @rus)

    empty = create_country("Пустая земля")
    guild = Guild.create!(name: "Гильдия-#{SecureRandom.hex(3)}", country: @rus)
    create_plant(guild, create_place(empty, "пустая"), 700)

    data = ManyTeams::AllTeamsResults.new.as_json

    assert_equal [@rus.id], data[:countries].map { |row| row[:country_id] }
    assert_not_includes data[:countries].map { |row| row[:country_id] }, empty.id
  end

  test "личный зачёт: знать ранжируется по влиянию среди всех команд" do
    rus_noble = create_player("Московский боярин", @noble_type, @rus)
    nov_noble = create_player("Новгородский боярин", @noble_type, @novgorod)
    add_influence(rus_noble, 1)
    add_influence(nov_noble, 4)

    nobles = ManyTeams::AllTeamsResults.new.as_json[:nobles]

    assert_equal %w[Новгородский Московский],
                 nobles.first(2).map { |row| row[:name].split.first }
    assert_equal [1, 2], nobles.first(2).map { |row| row[:place] }
    assert_equal @novgorod.id, nobles.first[:country_id]
  end

  test "личный зачёт: равное влияние делит место" do
    first = create_player("Первый", @noble_type, @rus)
    second = create_player("Второй", @noble_type, @novgorod)
    add_influence(first, 2)
    add_influence(second, 2)

    nobles = ManyTeams::AllTeamsResults.new.as_json[:nobles]

    assert_equal [1, 1], nobles.map { |row| row[:place] }
  end

  test "личный зачёт: купцы ранжируются по капиталу на игрока среди всех команд" do
    create_player("Боярин", @noble_type, @rus)

    single = Guild.create!(name: "Одиночка-#{SecureRandom.hex(3)}", country: @rus)
    Plant.create!(plant_level: nil, plant_place: nil, economic_subject: single)
    create_plant(single, create_place(@rus, "одиночка"), 4000)

    pair = Guild.create!(name: "Пара-#{SecureRandom.hex(3)}", country: @novgorod)
    create_plant(pair, create_place(@novgorod, "пара"), 4000)
    2.times { |i| Player.create!(name: "Купец#{i}-#{SecureRandom.hex(3)}", player_type: @merchant_type, country: @novgorod, guild: pair) }

    merchants = ManyTeams::AllTeamsResults.new.as_json[:merchants]
    row = merchants.find { |item| item[:guild_id] == pair.id }
    other = merchants.find { |item| item[:guild_id] == single.id }

    assert_equal 2, row[:number_of_players]
    assert_equal 2000, row[:cap_per_pl]
    assert_equal 4000, other[:cap_per_pl]
    assert_equal 1, other[:place]
    assert_equal 2, row[:place]
  end

  test "предприятие без земли не входит в зачёт и показывается отдельно" do
    create_player("Боярин", @noble_type, @rus)
    guild = Guild.create!(name: "Гильдия-#{SecureRandom.hex(3)}", country: @rus)
    Plant.create!(plant_level: nil, plant_place: nil, economic_subject: guild)

    data = ManyTeams::AllTeamsResults.new.as_json
    rows = rows_by_country(data)

    assert_equal 0, rows[@rus.id][:economy][:value]
    assert_equal 1, data[:plants_without_place][:count]
    assert_equal 0, data[:plants_without_place][:value]
  end
end
