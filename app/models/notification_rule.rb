# Маршрутизация уведомлений: какое событие каким мастерам показывать.
#
# Должности — свободная строка `users.job` (db/seeds/7_users.rb), поэтому
# сравнение идёт по нормализованной строке, а не по точному равенству.
class NotificationRule
  ECONOMY_JOB = 'Экономика'.freeze
  BATTLE_JOB = 'Сражения'.freeze
  POLICY_JOB = 'Политика'.freeze

  # Технология (константа Technology::*) → должности мастеров, которым нужно
  # знать об её открытии. Расширять этот список — единственное место правки.
  #
  # Экономические технологии открывают предприятия и улучшения (Сельские школы
  # разрешают улучшение, Ремесловые люди — Кузницу и Ювелирную мастерскую,
  # Технические училища дают ×1.5 перерабатывающим), поэтому их ждёт мастер
  # экономики; боевые технологии — мастер сражений.
  TECHNOLOGY_RECIPIENT_JOBS = {
    Technology::RURAL_SCHOOLS => [ECONOMY_JOB],
    Technology::CRAFTSMEN => [ECONOMY_JOB],
    Technology::TECH_SCHOOLS => [ECONOMY_JOB],
    Technology::BLACKSMITHING => [BATTLE_JOB],
    Technology::BALLISTICS => [BATTLE_JOB],
    Technology::CANNING => [BATTLE_JOB],
    Technology::FOREIGN_MERCE => [BATTLE_JOB]
  }.freeze

  # Итог сражения нужен обоим столам: сражения ведут бой, политика разыгрывает
  # его последствия (влияние, земли) — окно получают мастера обеих должностей.
  BATTLE_RESULT_JOBS = [BATTLE_JOB, POLICY_JOB].freeze

  # Крепости (постройка типа «Кремль») строят и улучшают за столом Мастера
  # сражений (dizdoc.md:228), от уровня укрепления зависят сила защищающихся
  # армий и влияние боярину, — окно адресуется только этой должности.
  FORTRESS_RECIPIENT_JOBS = [BATTLE_JOB].freeze

  ANONYMOUS_NAME = 'Аноним'.freeze

  # Латиница, похожая на кириллицу. В сиде должность подмастерья сражений
  # записана латинской «C» («Cражения»), и сравнение строк «как есть» оставило
  # бы половину мастеров сражений без уведомления.
  LOOKALIKES = {
    'A' => 'А', 'B' => 'В', 'C' => 'С', 'E' => 'Е', 'H' => 'Н',
    'K' => 'К', 'M' => 'М', 'O' => 'О', 'P' => 'Р', 'T' => 'Т',
    'X' => 'Х', 'Y' => 'У'
  }.freeze

  class << self
    # Открытие технологии: уведомление получают мастера профильной должности.
    # Государство уезжает и объектом `country` (герб и название в клиентах), и в
    # payload: окно должно сказать, ГДЕ технология открыта.
    # Возвращает созданные записи (пустой массив, если технология не в списке).
    def technology_opened(technology_item)
      technology = technology_item&.technology
      return [] if technology.nil?

      jobs = TECHNOLOGY_RECIPIENT_JOBS[technology.id]
      return [] if jobs.blank?

      country = technology_item.country

      Notification.deliver(
        kind: Notification::TECHNOLOGY_OPENED,
        title: "Открыта технология «#{technology.name}»",
        body: technology.description,
        users: users_by_jobs(jobs),
        technology: technology,
        country: country,
        payload: {
          'technology_id' => technology.id,
          'technology_name' => technology.name,
          'country_id' => country&.id,
          'country_name' => country&.name,
          'jobs' => jobs
        }
      )
    end

    # Земля перешла другому государству (Region#captured_by).
    #
    # Мастер экономики получает окно по землям ГОСУДАРСТВ ИГРОКОВ (набор
    # «Дашборда», ManyTeams::PlayerCountry): это его зона — там строят
    # предприятия, и окно подсказывает, какие добывающие предприятия теперь
    # доступны в государстве.
    # Мастер сражений получает окно по ЛЮБОМУ присоединению: карта войны меняется,
    # даже если за государство никто не играет.
    def region_annexed(region, previous_country, country, how)
      return [] if region.nil? || country.nil?

      how_text = how.to_i == Country::BY_WAR ? 'войной' : 'миром'
      player_country = player_country?(country)
      payload = {
        'region_id' => region.id,
        'region_name' => region.name,
        'country_id' => country.id,
        'country_name' => country.name,
        'previous_country_id' => previous_country&.id,
        'previous_country_name' => previous_country&.name,
        'how' => how_text,
        'player_country' => player_country
      }

      notifications = []

      if player_country
        plants = extractive_plant_hints(country)
        notifications += Notification.deliver(
          kind: Notification::REGION_ANNEXED,
          title: "Земля «#{region.name}» присоединена к государству «#{country.name}»",
          body: annexation_body(previous_country, how_text, plants),
          users: users_by_jobs([ECONOMY_JOB]),
          country: country,
          payload: payload.merge('audience' => 'economy', 'plants' => plants)
        )
      end

      notifications += Notification.deliver(
        kind: Notification::REGION_ANNEXED,
        title: "Земля «#{region.name}» присоединена к государству «#{country.name}»",
        body: annexation_body(previous_country, how_text, nil),
        users: users_by_jobs([BATTLE_JOB]),
        country: country,
        payload: payload.merge('audience' => 'battle', 'plants' => [])
      )

      notifications
    end

    # Крепость (постройка типа «Кремль», BuildingType::DEFENCE) в городе
    # построена или улучшена.
    #
    # Событие вызывается из Settlement#build (в том числе из политдействия
    # вассалов «Возвести форт») и из Building#upgrade!, а НЕ из колбэка Building:
    # сиды движков создают крепости напрямую (`Building.create`), и колбэк
    # слал бы окна при каждом прогоне сидов.
    #
    # `previous_level` — уровень ДО улучшения; при постройке не передаётся.
    # Возвращает созданные записи (пустой массив, если получателей нет).
    def fortress_changed(building, action, previous_level: nil)
      # Только по реально сохранённой постройке: `Building.create` возвращает
      # несохранённую запись при ошибке валидации (например, поселение не
      # найдено), и окно без города и уровня было бы мусором.
      return [] if building.nil? || !building.persisted?

      settlement = building.settlement
      building_level = building.building_level
      return [] if settlement.nil? || building_level.nil?

      country = building.country
      level = building_level.level
      level_name = building_level.name
      upgraded = action.to_s == 'upgraded'
      previous_name = previous_level_name(building, previous_level)

      parts = []
      parts << "Государство: «#{country.name}»." if country
      parts << "Земля: «#{settlement.region.name}»." if settlement.region
      parts << "Прежний уровень: «#{previous_name}» (#{previous_level})." if previous_name
      parts << if upgraded
                 'Город защищает крепость более высокого уровня.'
               else
                 'В городе появилась крепость — защита города усилена.'
               end

      Notification.deliver(
        kind: Notification::FORTRESS_CHANGED,
        title: "Крепость в городе «#{settlement.name}» #{upgraded ? 'улучшена' : 'построена'}: " \
               "«#{level_name}» (#{level} уровень)",
        body: parts.join(' '),
        users: users_by_jobs(FORTRESS_RECIPIENT_JOBS),
        country: country,
        payload: {
          'action' => upgraded ? 'upgraded' : 'built',
          'building_id' => building.id,
          'building_level' => level,
          'building_level_name' => level_name,
          'previous_level' => previous_level,
          'previous_level_name' => previous_name,
          'settlement_id' => settlement.id,
          'settlement_name' => settlement.name,
          'region_id' => settlement.region_id,
          'region_name' => settlement.region&.name,
          'country_id' => country&.id,
          'country_name' => country&.name
        }
      )
    end

    # Итог сражения. Клиент мастеров считает бой на планшете и присылает итог
    # (`POST /battles/report.json`), веб-админка считает 1×1 (`Army#attack`) —
    # оба пути приводят сюда, чтобы у мастеров было одно окно на одно событие.
    def battle_reported(attackers: nil, defenders: nil, winner_side: nil, outcome: nil,
                        place: nil, round: nil, fallen_troops: 0, winner_country: nil)
      attacker_names = labels(attackers)
      defender_names = labels(defenders)
      return [] if attacker_names.empty? && defender_names.empty?

      winner_label = winner_side.to_s == 'attacker' ? 'атакующие' : 'защищающиеся'

      body_parts = []
      body_parts << "Место: #{place}" if place.present?
      body_parts << "Раундов: #{round}" if round.present?
      body_parts << "Атакующие: #{attacker_names.join(', ')}" if attacker_names.any?
      body_parts << "Защищающиеся: #{defender_names.join(', ')}" if defender_names.any?
      body_parts << "Уничтожено отрядов: #{fallen_troops.to_i}" if fallen_troops.to_i.positive?

      Notification.deliver(
        kind: Notification::BATTLE_RESULT,
        title: "Сражение: победа — #{winner_label}",
        body: body_parts.join('. '),
        users: users_by_jobs(BATTLE_RESULT_JOBS),
        country: winner_country,
        payload: {
          'winner_side' => winner_side.to_s,
          'outcome' => outcome.to_s,
          'place' => place,
          'round' => round,
          'fallen_troops' => fallen_troops.to_i,
          'attackers' => attacker_names,
          'defenders' => defender_names,
          'winner_country_id' => winner_country&.id,
          'winner_country_name' => winner_country&.name
        }
      )
    end

    # Подписи армий из запроса клиента: [{"label" => "Армия (Иван)"}, "Гарнизон"].
    def labels(list)
      Array(list).map do |item|
        value = item.is_a?(Hash) ? (item['label'] || item['name'] || item[:label] || item[:name]) : item
        value.to_s.strip
      end.reject(&:blank?)
    end

    def users_by_jobs(jobs)
      wanted = Array(jobs).map { |job| fold(job) }
      return [] if wanted.empty?

      User.where.not(name: ANONYMOUS_NAME).select { |user| wanted.include?(fold(user.job)) }
    end

    def fold(value)
      value.to_s.strip.gsub(/[#{LOOKALIKES.keys.join}]/) { |char| LOOKALIKES[char] }.downcase
    end

    private

    # Земля отошла государству игроков? Набор «Дашборда» подтверждается мастерами
    # и живёт в движке many_teams; в базовой игре и artel движка нет — тогда
    # «государств игроков» не существует и окно экономике не адресуется.
    def player_country?(country)
      return false unless defined?(ManyTeams::PlayerCountry)

      ManyTeams::PlayerCountry.ids.include?(country.id)
    rescue StandardError
      false
    end

    # Добывающие предприятия, доступные в государстве: те, чей тип ископаемого
    # встречается хотя бы на одном добывающем месте его земель. Та же связка,
    # что в `PlantPlacesController#available_places` (plant_type.fossil_type_id →
    # plant_places.fossil_types).
    def extractive_plant_hints(country)
      extractive_ids = PlantCategory.where(is_extractive: true).ids
      return [] if extractive_ids.empty?

      fossil_ids = PlantPlace.where(plant_category_id: extractive_ids)
                             .joins(:region)
                             .where(regions: { country_id: country.id })
                             .joins(:fossil_types)
                             .pluck('fossil_types.id')
                             .uniq
      return [] if fossil_ids.empty?

      PlantType.where(plant_category_id: extractive_ids, fossil_type_id: fossil_ids)
               .includes(:fossil_type)
               .order(:id)
               .map do |type|
                 {
                   'plant_type_id' => type.id,
                   'plant_type_name' => type.name,
                   'fossil_type_name' => type.fossil_type&.name
                 }
               end
    end

    # Название прежнего уровня крепости: уровни нумерованы в пределах своего типа
    # постройки (1 «Форт», 2 «Крепость», 3 «Кремль»), поэтому искать по паре
    # «уровень + тип», а не по номеру уровня вообще.
    def previous_level_name(building, previous_level)
      return nil if previous_level.blank?

      BuildingLevel.find_by(level: previous_level, building_type_id: building.building_level&.building_type_id)&.name
    end

    def annexation_body(previous_country, how_text, plants)
      parts = []
      parts << if previous_country
                 "Прежнее государство: «#{previous_country.name}». Земля присоединена #{how_text}."
               else
                 "Земля присоединена #{how_text}."
               end

      # plants == nil — окно мастеру сражений: подсказка про предприятия ему не нужна.
      unless plants.nil?
        if plants.any?
          parts << 'Теперь в государстве можно строить добывающие предприятия: ' \
                   "#{plants.map { |plant| plant['plant_type_name'] }.join(', ')}."
        else
          parts << 'Добывающих предприятий в этих землях нет.'
        end
      end

      parts.join(' ')
    end
  end
end
