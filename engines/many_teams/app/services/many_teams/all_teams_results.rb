# Табло «Результаты всех команд» для окон «Служебное → Вывод На Экран».
#
# Считается сразу по ВСЕМ командам игры — в отличие от экранов результатов ядра
# (`screen_bundle`, `show_noble_results`, `show_sorted_results`), которые относятся
# к одному государству. Только чтение, ничего не пишет.
#
# Общий зачёт — два независимых показателя; место считается по каждому отдельно,
# сводного (итогового) места нет — так решил заказчик, победителя объявляет мастер:
#   * экономика — сумма залоговой стоимости предприятий (`plant_levels.deposit`),
#     построенных на землях государства: `plants.plant_place_id` → `plant_places`
#     → `regions.country_id`. Тот же смысл, что у `Plant#build_country`, и та же
#     величина, что входит в капитал гильдии (`GameParameter.show_sorted_results`,
#     «стоимость предприятий (сумма deposit)»);
#   * политика — сумма `Player#influence(country)` по игрокам государства, то есть
#     общее количество очков влияния в государстве (влияние от InfluenceItem за всю
#     игру плюс влияние от зданий — без фильтра по году).
#
# Личный зачёт — как на существующих экранах результатов: знать по влиянию
# (`GameParameter.show_noble_results`) и гильдии по капиталу на игрока
# (`GameParameter.show_sorted_results` + `find_cap_per_pl`). Отличие одно: места
# считаются по всем командам сразу, а не внутри государства.
#
# В зачёт входят только государства, за которые играют (есть хотя бы один игрок):
# иначе пустые государства занимали бы половину табло.
module ManyTeams
  class AllTeamsResults
    def as_json(*)
      countries = playing_countries
      players = players_of(countries)
      influence = influence_by_player(players, countries)

      economy = economy_by_country
      politics = politics_by_country(players, influence)

      {
        year: ::GameParameter.current_year,
        source: 'live',
        countries: country_rows(countries, players, economy, politics),
        nobles: noble_rows(players, influence),
        merchants: merchant_rows(countries),
        plants_without_place: plants_without_place
      }
    end

    private

    # Государства, за которые играют. Порядок — по названию; строки табло
    # сортируются по экономике в `country_rows`.
    def playing_countries
      ids = ::Player.where.not(country_id: nil).distinct.pluck(:country_id)
      ::Country.where(id: ids).order(:name).to_a
    end

    def players_of(countries)
      return [] if countries.empty?

      ::Player.includes(:influence_items)
              .where(country_id: countries.map(&:id))
              .order(:name)
              .to_a
    end

    # Влияние в СВОЁМ государстве — то же, что показывает `show_noble_results`
    # (там `player.influence(country)`), и то же, что суммируется в политический
    # показатель. Считаем один раз на игрока: `influence` тянет здания отдельными
    # запросами, а `influence_items` подгружены через includes.
    def influence_by_player(players, countries)
      by_country_id = countries.index_by(&:id)

      players.each_with_object({}) do |player, acc|
        country = by_country_id[player.country_id]
        next if country.nil?

        acc[player.id] = player.influence(country).to_i
      end
    end

    def politics_by_country(players, influence)
      players.each_with_object(Hash.new(0)) do |player, acc|
        acc[player.country_id] += influence[player.id].to_i
      end
    end

    # Стоимость предприятий в разрезе государства-земли, а не государства владельца:
    # предприятие чужой гильдии на московской земле даёт очки Москве.
    def economy_by_country
      totals = {}

      plants_with_place.each do |plant|
        country_id = plant.plant_place&.region&.country_id
        next if country_id.nil?

        row = totals[country_id] ||= { value: 0, plants_count: 0 }
        row[:value] += plant.plant_level&.deposit.to_i
        row[:plants_count] += 1
      end

      totals
    end

    def plants_with_place
      ::Plant.includes(:plant_level, plant_place: :region).where.not(plant_place_id: nil)
    end

    # Предприятия без участка (артель, старые записи) не попадают ни в одно
    # государство. Показываем их отдельной строкой, чтобы сумма на табло не
    # расходилась с базой без объяснения.
    def plants_without_place
      plants = ::Plant.includes(:plant_level).where(plant_place_id: nil).to_a

      { count: plants.size, value: plants.sum { |plant| plant.plant_level&.deposit.to_i } }
    end

    def country_rows(countries, players, economy, politics)
      players_count = players.each_with_object(Hash.new(0)) do |player, acc|
        acc[player.country_id] += 1
      end

      rows = countries.map do |country|
        eco = economy[country.id] || { value: 0, plants_count: 0 }
        pol = politics[country.id].to_i

        {
          country_id: country.id,
          name: country.name,
          short_name: country.short_name,
          flag_image_name: country.flag_image_name,
          players_count: players_count[country.id],
          economy: { value: eco[:value].to_i, plants_count: eco[:plants_count].to_i },
          politics: { value: pol }
        }
      end

      eco_places = places_for(rows.map { |row| row[:economy][:value] })
      pol_places = places_for(rows.map { |row| row[:politics][:value] })

      rows.each do |row|
        row[:economy][:place] = eco_places[row[:economy][:value]]
        row[:politics][:place] = pol_places[row[:politics][:value]]
      end

      # Экономика — первый столбец зачёта, по ней и порядок строк; при равенстве
      # выше то государство, у которого больше очков влияния.
      rows.sort_by { |row| [-row[:economy][:value], -row[:politics][:value], row[:name].to_s] }
    end

    def noble_rows(players, influence)
      by_country_id = ::Country.where(id: players.map(&:country_id).uniq).index_by(&:id)

      rows = players.filter_map do |player|
        next unless player.player_type_id == ::PlayerType::NOBLE

        country = by_country_id[player.country_id]
        value = influence[player.id].to_i
        # Как в `show_noble_results`: «дух бунта» без влияния в зачёт не попадает
        next if player.name == ::PlayerType::REBEL_NAME && value.zero?

        {
          player_id: player.id,
          name: player.name,
          country_id: country&.id,
          country_name: country&.name,
          short_name: country&.short_name,
          flag_image_name: country&.flag_image_name,
          influence: value
        }
      end

      ranked(rows, :influence)
    end

    # Капитал и число игроков гильдии берём готовым расчётом ядра (там же деньги и
    # боярская милость из `results.guild_extra_data` и ручное число игроков), а
    # места пересчитываем по всем командам — иначе у каждого государства была бы
    # своя первая строчка.
    def merchant_rows(countries)
      rows = countries.flat_map do |country|
        ::GameParameter.show_sorted_results(country: country).map do |guild_result|
          {
            guild_id: guild_result[:guild_id],
            name: guild_result[:player],
            country_id: country.id,
            country_name: country.name,
            short_name: country.short_name,
            flag_image_name: country.flag_image_name,
            capital: guild_result[:capital].to_i,
            cap_per_pl: guild_result[:cap_per_pl].to_i,
            gold: guild_result[:gold].to_i,
            plants_value: guild_result[:plants_value].to_i,
            number_of_players: guild_result[:number_of_players].to_i
          }
        end
      end

      ranked(rows, :cap_per_pl)
    end

    # Места как в остальных экранах результатов: равные значения делят место,
    # следующее значение получает следующее место (1, 1, 2).
    def places_for(values)
      values.uniq.sort.reverse.each_with_index.to_h { |value, index| [value, index + 1] }
    end

    def ranked(rows, key)
      places = places_for(rows.map { |row| row[key].to_i })

      rows.each { |row| row[:place] = places[row[key].to_i] }
      rows.sort_by { |row| [-row[key].to_i, row[:name].to_s] }
    end
  end
end
