require "test_helper"

# Передача региона государству: `Region#captured_by` (кнопка «Присоединить регион»
# в клиенте мастеров и «Передать регион» в веб-админке).
#
# Правило заказчика: событие общественного порядка создаётся только тогда, когда за
# государство-получателя играют игроки; если игроков нет, отыгрывать изменение
# порядка некому и запись не пишется. Владения прежних владельцев снимаются только
# при передаче чужому государству.
class RegionCaptureTest < ActiveSupport::TestCase
  # Фикстуры репозитория не соответствуют схеме — данные создаём сами
  self.fixture_table_names = []

  setup do
    GameParameter.find_or_create_by(identificator: "current_year") do |gp|
      gp.name = "Текущий год"
      gp.value = "1"
    end

    @player_type = PlayerType.find_by(id: PlayerType::NOBLE) ||
                   PlayerType.create!(id: PlayerType::NOBLE, name: "Знать")
    @settlement_type = SettlementType.first ||
                       SettlementType.create!(name: "Город", params: { "income" => 1000 })

    # Государство, за которое играют (текущее), и государство без игроков
    @played = Country.create!(name: "Тест-Москва-#{SecureRandom.hex(3)}", short_name: "Москва", params: {})
    @empty = Country.create!(name: "Тест-Орда-#{SecureRandom.hex(3)}", short_name: "Орда", params: {})
    Player.create!(name: "Боярин-#{SecureRandom.hex(3)}", player_type: @player_type, country: @played)

    @region = Region.create!(name: "Тест-земля-#{SecureRandom.hex(3)}", country: @empty)
    # Владелец города — игрок играющего государства: его владение лежит в чужой земле
    @owner = Player.create!(name: "Владелец-#{SecureRandom.hex(3)}", player_type: @player_type, country: @played)
    @settlement = Settlement.create!(
      name: "Тест-город-#{SecureRandom.hex(3)}",
      region: @region,
      settlement_type: @settlement_type,
      player: @owner
    )

    Country.current = @played
  end

  teardown do
    Thread.current[:current_country] = nil
  end

  test "страна с игроками получает запись общественного порядка «войной»" do
    result = @region.captured_by(@played.id, 1)

    assert result[:result]
    assert_equal @played.id, @region.reload.country_id
    assert_equal 1, @region.public_order_items.count
    item = @region.public_order_items.first
    assert_equal Country::MILITARILY, item.value
    assert_equal "Регион присоединен войной", item.comment
  end

  test "страна с игроками получает запись общественного порядка «миром»" do
    @region.captured_by(@played.id, 0)

    item = @region.reload.public_order_items.first
    assert_equal Country::PEACEFULLY, item.value
    assert_equal "Регион присоединен миром", item.comment
  end

  test "страна без игроков: регион переходит, событие порядка не создаётся" do
    @region.update!(country: @played)

    result = @region.captured_by(@empty.id, 1)

    assert result[:result]
    assert_equal @empty.id, @region.reload.country_id
    assert_equal 0, @region.public_order_items.count
  end

  test "чужое государство снимает владельцев поселений" do
    @region.update!(country: @played)

    @region.captured_by(@empty.id, 1)

    assert_nil @settlement.reload.player_id
  end

  test "текущее государство сохраняет владельцев поселений" do
    @region.captured_by(@played.id, 1)

    assert_equal @owner.id, @settlement.reload.player_id
  end

  test "неизвестное государство не меняет регион" do
    result = @region.captured_by(0, 1)

    assert_not result[:result]
    assert_equal @empty.id, @region.reload.country_id
    assert_equal 0, @region.public_order_items.count
  end

  test "повторная передача тому же государству не добавляет событий" do
    @region.captured_by(@played.id, 1)
    @region.captured_by(@played.id, 1)

    assert_equal 1, @region.reload.public_order_items.count
  end

  # ---- Влияние за землю: Посольский дьяк +7, Князь +5 за КАЖДУЮ землю ----

  test "бонус за землю начисляется Посольскому дьяку и Князю получателя" do
    posol = council_member(@played, Job::POSOL, "Посол")
    knyaz = council_member(@played, Job::GRAND_PRINCE, "Князь")

    result = @region.captured_by(@played.id, 1, posol: true, grand_prince: true)

    assert_equal [Job::POSOL_BONUS, Job::GRAND_PRINCE_BONUS], result[:awarded].map { |row| row[:value] }
    assert_equal Job::POSOL_BONUS, Player.find(posol.id).influence(@played)
    assert_equal Job::GRAND_PRINCE_BONUS, Player.find(knyaz.id).influence(@played)
  end

  test "без флагов мастера влияние за землю не начисляется" do
    posol = council_member(@played, Job::POSOL, "Посол")

    result = @region.captured_by(@played.id, 1)

    assert_empty result[:awarded]
    assert_equal 0, Player.find(posol.id).influence(@played)
  end

  test "земля ушла другим игрокам: у прежнего государства бонус снимается" do
    old_posol = council_member(@empty, Job::POSOL, "Посол-прежний")
    old_knyaz = council_member(@empty, Job::GRAND_PRINCE, "Князь-прежний")

    result = @region.captured_by(@played.id, 1, remove_posol: true, remove_grand_prince: true)

    assert_equal [-Job::POSOL_BONUS, -Job::GRAND_PRINCE_BONUS], result[:awarded].map { |row| row[:value] }
    assert_equal(-Job::POSOL_BONUS, Player.find(old_posol.id).influence(@empty))
    assert_equal(-Job::GRAND_PRINCE_BONUS, Player.find(old_knyaz.id).influence(@empty))
  end

  test "присоединение страны миром: бонус за каждую землю, а не за государство" do
    2.times do |i|
      Region.create!(name: "Тест-земля-#{i}-#{SecureRandom.hex(3)}", country: @empty)
    end
    posol = council_member(@played, Job::POSOL, "Посол")
    lands = @empty.regions.count

    result = @empty.join_peace(@played, posol: true)

    assert result[:result]
    assert_equal lands, result[:regions_count]
    assert_equal Array.new(lands, Job::POSOL_BONUS), result[:awarded].map { |row| row[:value] }
    assert_equal lands * Job::POSOL_BONUS, Player.find(posol.id).influence(@played)
  end

  private

  # Игрок государства на должности (должность создаётся, если её нет)
  def council_member(country, job_id, name)
    job = Job.find_or_create_by(id: job_id) do |record|
      record.name = "Должность #{job_id}"
    end
    player = Player.create!(
      name: "#{name}-#{SecureRandom.hex(3)}",
      player_type: @player_type,
      country: country
    )
    player.jobs << job
    player
  end
end
