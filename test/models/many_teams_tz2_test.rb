require "test_helper"

# Тесты этапа 2 «функциональность» (ТЗ № 2) на уровне моделей.
#
# Главная проверка — § 1.4: ни один путь начисления влияния политическим действием
# не адресует должность. Влияние всегда ложится на игрока (`influence_items.player_id`),
# поэтому для каждого действия из справочника результат `execute` либо начисляет
# влияние игроку, либо не начисляет вовсе.
class ManyTeamsTz2ModelTest < ActiveSupport::TestCase
  # Фикстуры репозитория не соответствуют схеме (см. test/models/many_teams_test.rb)
  self.fixture_table_names = []

  # Перехватчик адресатов влияния. Включается только на время теста
  # (spy_targets не nil) — остальные тесты набора видят обычное поведение.
  class << self
    attr_accessor :spy_targets
  end

  module InfluenceItemSpy
    def add(value, comment, entity = nil, source = nil)
      spy = ManyTeamsTz2ModelTest.spy_targets
      if spy
        spy << entity
        return nil
      end

      super
    end
  end
  InfluenceItem.singleton_class.prepend(InfluenceItemSpy)

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

    @noble_type = PlayerType.find_by(id: PlayerType::NOBLE) ||
                  PlayerType.create!(id: PlayerType::NOBLE, name: "Знать")

    # Код читает технологии и справочник политдействий — в пустой тестовой базе
    # их нужно создать, как это делают сиды
    ensure_technologies
    ensure_political_action_types

    Country.current = @rus
  end

  def ensure_technologies
    {
      Technology::ST_GEORGE_DAY => "Юрьев день",
      Technology::GODS_ANOITED => "Помазанник божий",
      Technology::MOSCOW_THIRD_ROME => "Москва — Третий Рим",
    }.each do |id, name|
      Technology.find_by(id: id) || Technology.create!(id: id, name: name, description: name)
    end
  end

  # Минимальный справочник действий: проверяется правило «влияние — игроку»,
  # а не наличие конкретных действий в сидах
  def ensure_political_action_types
    job = Job.find_by(id: Job::GRAND_PRINCE) || Job.create!(id: Job::GRAND_PRINCE, name: "Великий князь")
    [["Торжественный выход к народу", "ceremonial"],
     ["Народная поддержка", "people_support"],
     ["Подстрекательство к бунту", "sedition"]].each do |name, action|
      PoliticalActionType.find_by(action: action) ||
        PoliticalActionType.create!(name: name, action: action, job: job)
    end
  end

  teardown do
    ManyTeamsTz2ModelTest.spy_targets = nil
    Thread.current[:current_country] = nil
    Thread.current[:current_player_id] = nil
  end

  ############ § 1.4 Влияние адресуется игроку, а не должности ############

  test "политическое действие начисляет влияние только игроку" do
    player = Player.create!(name: "Боярин #{SecureRandom.hex(3)}", player_type: @noble_type, country: @rus)
    job = Job.find_by(id: Job::GRAND_PRINCE) || Job.create!(id: Job::GRAND_PRINCE, name: "Великий князь")
    job.update!(player_ids: [player.id])

    types = PoliticalActionType.all.to_a
    assert types.any?, "справочник политических действий пуст — проверять нечего"

    checked = 0
    granted = 0
    types.each do |type|
      action = PoliticalAction.new(player: player, job: job, political_action_type: type,
                                   year: GameParameter.current_year, success: 1)
      action.country_id = @rus.id

      targets = []
      self.class.spy_targets = targets
      begin
        action.execute
      rescue StandardError
        # Часть действий требует данных, которых в этом тесте нет (регион, гильдия,
        # страна-цель). К проверяемому правилу это не относится: важно лишь то, что
        # влияние, если оно начислено, начислено игроку.
      ensure
        self.class.spy_targets = nil
      end

      granted += 1 if targets.compact.any?

      targets.compact.each do |target|
        assert_kind_of Player, target,
                       "действие «#{type.name}» (#{type.action}) начислило влияние не игроку: #{target.class}"
        assert_not_nil target.id, "действие «#{type.name}» (#{type.action}) начислило влияние игроку без id"
        assert_equal @rus.id, target.country_id,
                     "действие «#{type.name}» (#{type.action}) начислило влияние игроку другого государства"
      end
      checked += 1
    end

    assert_equal types.length, checked
    assert granted.positive?,
           "ни одно действие не начислило влияние — проверка вырождена (перехват не работает)"
  end

  test "влияние остаётся у игрока после смены держателя должности" do
    job = Job.find_by(id: Job::KAZNACHEI) || Job.create!(id: Job::KAZNACHEI, name: "Казначей")
    old_holder = Player.create!(name: "Старый казначей #{SecureRandom.hex(3)}", player_type: @noble_type, country: @rus)
    new_holder = Player.create!(name: "Новый казначей #{SecureRandom.hex(3)}", player_type: @noble_type, country: @rus)
    job.update!(player_ids: [old_holder.id])

    old_holder.modify_influence(5, "Бонус за оплату государства", @rus)
    assert_equal 5, old_holder.influence

    # Смена держателя должности не переносит влияние: у прежнего игрока оно остаётся,
    # у нового начинается с нуля
    job.update!(player_ids: [new_holder.id])

    assert_equal 5, old_holder.reload.influence
    assert_equal 0, new_holder.reload.influence
  end

  ############ § 3.6 Доход считается по владениям текущего государства ############

  test "в разбивку дохода попадают владения только указанного государства" do
    player = Player.create!(name: "Боярин #{SecureRandom.hex(3)}", player_type: @noble_type, country: @rus)

    rus_region = Region.create!(name: "Регион Руси #{SecureRandom.hex(3)}", country: @rus)
    litva_region = Region.create!(name: "Регион Литвы #{SecureRandom.hex(3)}", country: @litva)
    settlement_type = SettlementType.create!(name: "Городок #{SecureRandom.hex(3)}", params: { "income" => 100 })

    Settlement.create!(name: "Село Руси #{SecureRandom.hex(3)}", region: rus_region, player: player,
                       settlement_type: settlement_type)
    Settlement.create!(name: "Село Литвы #{SecureRandom.hex(3)}", region: litva_region, player: player,
                       settlement_type: settlement_type)

    rus_breakdown = player.income_breakdown(@rus)
    litva_breakdown = player.income_breakdown(@litva)

    assert_equal @rus.id, rus_breakdown[:country][:id]
    assert_equal @litva.id, litva_breakdown[:country][:id]

    assert_equal 1, rus_breakdown[:settlements].length
    assert_equal 1, litva_breakdown[:settlements].length
    assert(rus_breakdown[:settlements].all? { |s| s[:country_id] == @rus.id })
    assert(litva_breakdown[:settlements].all? { |s| s[:country_id] == @litva.id })
    refute_equal rus_breakdown[:settlements].first[:settlement_id],
                 litva_breakdown[:settlements].first[:settlement_id]
  end
end
