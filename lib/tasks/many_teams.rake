# Задачи перехода на режим «несколько команд» (ТЗ № 1, § 11 / § 13 п. 6 / § 14 п. 6).
#
# Все задачи идемпотентны: они заполняют только «пустые» значения (NULL, скаляры,
# отсутствующие ключи), поэтому повторный запуск не портит уже разделённые по
# государствам данные.
namespace :many_teams do
  desc "Предпроверка перед миграцией 4: дубли technology_items по technology_id"
  task precheck: :environment do
    duplicates = TechnologyItem.group(:technology_id).having("count(*) > 1").count
    if duplicates.empty?
      puts "Предпроверка пройдена: дублей technology_items по technology_id нет"
    else
      puts "ВНИМАНИЕ: найдены дубли technology_items по technology_id — уникальный индекс (technology_id, country_id) не накатится:"
      duplicates.each { |technology_id, count| puts "  technology_id=#{technology_id}: #{count} строк" }
      puts "Разберите дубли вручную (склейка значений) и повторите миграцию."
    end

    self_pairs = RelationItem.where("country_id = partner_country_id").count
    puts "Самопар relation_items (country_id = partner_country_id): #{self_pairs}"
  end

  desc "Отчёт о состоянии данных в разрезе государств (§ 11)"
  task report: :environment do
    rus = Country.find_by(id: Country::RUS)
    puts "Государство по умолчанию: #{rus ? "#{rus.id} — #{rus.name}" : 'не найдено'}"

    {
      "Player" => Player.where(country_id: nil).count,
      "Guild" => Guild.where(country_id: nil).count,
      "TechnologyItem" => TechnologyItem.where(country_id: nil).count,
      "PoliticalAction" => PoliticalAction.where(country_id: nil).count,
      "RelationItem" => RelationItem.where(partner_country_id: nil).count
    }.each do |model, count|
      puts "#{model} без государства: #{count}"
    end

    self_pairs = RelationItem.where("country_id = partner_country_id")
    puts "Самопар relation_items: #{self_pairs.count}"
    self_pairs.group(:country_id).count.each { |country_id, count| puts "  country_id=#{country_id}: #{count}" }

    Country.order(:id).each do |country|
      puts "  #{country.id} #{country.name}: игроков=#{country.players.count}, " \
           "гильдий=#{country.guilds.count}, регионов=#{country.regions.count}, " \
           "технологий открыто=#{country.technology_items.where(value: 1).count}, " \
           "расходы оплачены(#{GameParameter.current_year})=#{country.state_expenses_paid?}"
    end
  end

  desc "Проверки ТЗ № 1 (§ 12) на текущей базе: паритет и разрезы по государствам"
  task verify: :environment do
    # По умолчанию только чтение; изменяющие проверки — с MUTATING=1
    load Rails.root.join("lib/many_teams/verify.rb")
  end

  desc "Бэкфилл данных под режим «несколько команд» (однократно, до начала игры)"
  task backfill: :environment do
    rus = Country.find_by(id: Country::RUS)
    if rus.nil?
      abort "Государство «Русь» (id=#{Country::RUS}) не найдено — бэкфилл невозможен"
    end

    puts "Бэкфилл к государству «#{rus.name}» (id=#{rus.id})"

    # 1. Существующие записи относились к «Руси». Обновляем только незаполненные
    #    значения, чтобы повторный запуск не переписывал уже разделённые данные.
    changed = {
      players: Player.where(country_id: nil).update_all(country_id: rus.id),
      guilds: Guild.where(country_id: nil).update_all(country_id: rus.id),
      technology_items: TechnologyItem.where(country_id: nil).update_all(country_id: rus.id),
      political_actions: PoliticalAction.where(country_id: nil).update_all(country_id: rus.id),
      relation_items: RelationItem.where(partner_country_id: nil).where.not(country_id: rus.id).update_all(partner_country_id: rus.id)
    }
    changed.each { |model, count| puts "  #{model}: обновлено #{count}" }

    # 1b. Самопара «Русь — Русь» смысла не имеет (§ 8.9): у собственной записи
    # отношений «Руси» второй конец остаётся пустым (как при чистом сидировании).
    # На чтение это не влияет: величина отношений — сумма собственных записей.
    self_pairs = RelationItem.where("country_id = partner_country_id")
    cleared = self_pairs.update_all(partner_country_id: nil)
    puts "  самопар отношений развязано: #{cleared}"

    # 1a. Факт открытия технологии — на пару «технология × государство» (§ 8.5, § 10 п. 1):
    # в старой базе строки были только на пары с «Русью», поэтому у остальных государств
    # открытие технологии молча ничего не делало. Создаём отсутствующие пары со значением 0.
    technology_items_created = 0
    Country.find_each do |country|
      Technology.find_each do |technology|
        next if TechnologyItem.exists?(technology_id: technology.id, country_id: country.id)

        TechnologyItem.create!(
          technology_id: technology.id,
          country_id: country.id,
          value: 0,
          comment: "Изменить значение",
          year: GameParameter.current_year
        )
        technology_items_created += 1
      end
    end
    puts "  technology_items по парам «технология × государство»: создано #{technology_items_created}"

    # 2. params: скаляры → хэши по паре государств
    countries_params = 0
    Country.find_each do |country|
      params = country.params || {}
      next if params['relation_points'].is_a?(Hash) && params['last_trade_turnover'].is_a?(Hash)

      points = params['relation_points'].is_a?(Hash) ? params['relation_points'] : { rus.id.to_s => params['relation_points'].to_i }
      turnover = params['last_trade_turnover'].is_a?(Hash) ? params['last_trade_turnover'] : { rus.id.to_s => params['last_trade_turnover'].to_i }

      params['relation_points'] = points
      params['last_trade_turnover'] = turnover
      country.update_column(:params, params)
      countries_params += 1
    end
    puts "  params государств (relation_points/last_trade_turnover → пары): обновлено #{countries_params}"

    # 3. Расходы государства: общий флаг игры → флаг по годам у «Руси» (Д12)
    year = GameParameter.current_year
    current_year_parameter = GameParameter.find_by(identificator: "current_year")
    legacy_flag = current_year_parameter&.params&.[]('state_expenses')
    expenses_params = 0
    Country.find_each do |country|
      params = country.params || {}
      if params['state_expenses'].is_a?(Hash)
        if country.id == rus.id && !params['state_expenses'].key?(year.to_s) && !legacy_flag.nil?
          params['state_expenses'][year.to_s] = legacy_flag
          country.update_column(:params, params)
          expenses_params += 1
        end
        next
      end

      value = country.id == rus.id ? legacy_flag : nil
      next if value.nil?

      params['state_expenses'] = { year.to_s => value }
      country.update_column(:params, params)
      expenses_params += 1
    end
    puts "  расходы государства: обновлено #{expenses_params} (год #{year})"

    # Прежний общий флаг больше не читается — убираем, чтобы он не «воскрес»
    if current_year_parameter && current_year_parameter.params&.key?('state_expenses')
      current_year_parameter.params.delete('state_expenses')
      current_year_parameter.save
      puts "  params current_year: общий флаг state_expenses удалён"
    end

    # 4. Результаты игры: скаляры display и настроек → хэши по государствам (Д13)
    results_parameter = GameParameter.find_by(identificator: "results")
    if results_parameter
      params = results_parameter.params || {}
      migrated = []

      if params['display'] && !params['display'].is_a?(Hash)
        params['display'] = { rus.id.to_s => params['display'] }
        migrated << 'display'
      end

      if !params['merchant_settings'].is_a?(Hash)
        settings = {}
        settings['show_cap_per_player'] = params['show_cap_per_player'] unless params['show_cap_per_player'].nil?
        if settings.present?
          params['merchant_settings'] = { rus.id.to_s => settings }
          migrated << 'merchant_settings'
        end
      end

      if migrated.any?
        results_parameter.update_column(:params, params)
        puts "  результаты игры: перенесены #{migrated.join(', ')}"
      else
        puts "  результаты игры: перенос не требуется"
      end
    else
      puts "  результаты игры: запись results не найдена"
    end

    # 5. Снимок текущего года выполняется один раз при выкатке (иначе годовые
    #    результаты перезаписываются текущими при ближайшей смене года)
    snapshot = GameParameter.snapshot_year_results(GameParameter.current_year)
    puts "  снимок результатов года #{GameParameter.current_year} готов: государств #{snapshot&.keys&.length.to_i}"

    puts "Бэкфилл завершён. Отчёт: rake many_teams:report"
  end
end
