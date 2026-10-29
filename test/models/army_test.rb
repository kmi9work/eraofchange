require "test_helper"

# Влияние Воеводе за сражение (решение заказчика): +4 за КАЖДУЮ разбитую армию
# противника совету Воеводы победителя и −1 за каждую разбитую армию своего
# государства совету Воеводы проигравшего. Гарнизон города армией не является и в
# начислении не участвует (клиент такие армии в списки не передаёт).
class ArmyTest < ActiveSupport::TestCase
  # Фикстуры репозитория не соответствуют схеме — данные создаём сами
  self.fixture_table_names = []

  setup do
    GameParameter.find_or_create_by(identificator: "current_year") do |gp|
      gp.name = "Текущий год"
      gp.value = "1"
    end

    @player_type = PlayerType.find_by(id: PlayerType::NOBLE) ||
                   PlayerType.create!(id: PlayerType::NOBLE, name: "Знать")

    @winner = Country.create!(name: "Тест-победитель-#{SecureRandom.hex(3)}", short_name: "Победитель", params: {})
    @loser = Country.create!(name: "Тест-проигравший-#{SecureRandom.hex(3)}", short_name: "Проигравший", params: {})

    @voevoda_winner = council_member(@winner, Job::VOEVODA, "Воевода-победитель")
    @voevoda_loser = council_member(@loser, Job::VOEVODA, "Воевода-проигравший")

    @winning_army = Army.create!(name: "Победитель-#{SecureRandom.hex(3)}",
                                 owner_type: "Country", owner_id: @winner.id)
    @defeated_armies = 2.times.map do |i|
      Army.create!(name: "Разбитая-#{i}-#{SecureRandom.hex(3)}",
                   owner_type: "Country", owner_id: @loser.id)
    end
  end

  test "за каждую разбитую армию победитель получает +4, проигравший -1" do
    rows = Army.award_victory_influence([@winning_army], @defeated_armies)

    bonuses = rows.select { |row| row[:role] == "bonus" }
    penalties = rows.select { |row| row[:role] == "penalty" }

    assert_equal [Job::VOEVODA_BONUS * 2], bonuses.map { |row| row[:value] }
    assert_equal [Job::VOEVODA_PENALTY * 2], penalties.map { |row| row[:value] }
    assert_equal Job::VOEVODA_BONUS * 2, Player.find(@voevoda_winner.id).influence(@winner)
    assert_equal Job::VOEVODA_PENALTY * 2, Player.find(@voevoda_loser.id).influence(@loser)
  end

  test "одна разбитая армия — ровно +4 и -1" do
    rows = Army.award_victory_influence([@winning_army], [@defeated_armies.first])

    assert_equal [Job::VOEVODA_BONUS, Job::VOEVODA_PENALTY], rows.map { |row| row[:value] }
  end

  test "без разбитых армий (например, разбит только гарнизон) влияние не начисляется" do
    rows = Army.award_victory_influence([@winning_army], [])

    assert_empty rows
    assert_equal 0, Player.find(@voevoda_winner.id).influence(@winner)
  end

  test "должность командующего роли не играет: победа любой армии государства даёт бонус Воеводе" do
    noble = Player.create!(name: "Боярин-#{SecureRandom.hex(3)}", player_type: @player_type, country: @winner)
    army = Army.create!(name: "Боярская-#{SecureRandom.hex(3)}", owner_type: "Player", owner_id: noble.id)

    rows = Army.award_victory_influence([army], [@defeated_armies.first])

    assert_equal [Job::VOEVODA_BONUS], rows.select { |row| row[:role] == "bonus" }.map { |row| row[:value] }
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
