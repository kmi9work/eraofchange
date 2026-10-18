class Country < ApplicationRecord
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
  # state_expenses (hash по годам) - {"3" => true} — подтверждена ли оплата госрасходов в этом году
  # relation_points (hash по partner_country_id) - торговые очки для пары государств
  # last_trade_turnover (hash по partner_country_id) - последний учтённый товарооборот пары
  audited if: :should_audit?

  has_many :regions
  has_many :relation_items
  has_many :armies
  has_many :caravans
  has_many :alliances
  has_many :partner_alliances, class_name: 'Alliance', foreign_key: 'partner_country_id'
  has_many :resources
  has_many :players
  has_many :guilds
  has_many :technology_items
  has_many :political_actions
  # Армии, которыми владеет само государство (владелец — Country, не игрок)
  has_many :owned_armies, -> { where(owner_type: 'Country') }, class_name: 'Army', foreign_key: :owner_id

  REL_RANGE = 2   # relations (interger) - уровень отношений с Русью от -2 до 2

  # Бонус от технологии "Москва — Третий Рим" (можно переопределить в плагинах)
  class_attribute :moscow_third_rome_bonus, default: 2

  # Функционал управления союзами (можно включить в плагинах)
  class_attribute :alliances_enabled, default: false

  RUS = 1         #Русь
  HORDE = 2       #Большая орда
  LIVONIAN = 3    #Ливонский орден
  SWEDEN = 4      #Швеция
  LITHUANIA = 5   #Великое княжество литовское
  KAZAN = 6       #Казанское ханство
  CRIMEA = 7      #Крымское ханство

  PERMIAN = 8     #Пермь
  VYATKA = 9      #Вятка
  RYAZAN = 10     #Рязань
  TVER = 11       #Тверь
  NOVGOROD = 12   #Великий Новгород

  BY_WAR = 1
  BY_DIPLOMACY = 0

  MILITARILY = -3
  PEACEFULLY = 3

  # Государства, которым технология "Москва — Третий Рим" даёт бонус в паре с «Русью»
  THIRD_ROME_BONUS_COUNTRIES = [PERMIAN, VYATKA, RYAZAN, TVER, NOVGOROD].freeze

  #Иностранные государства
  scope :foreign_countries, -> {where(id: [HORDE, LIVONIAN, SWEDEN, LITHUANIA, KAZAN, CRIMEA])}
  
  #Русские государства ЗА ИСКЛЮЧЕНИЕМ ВЯТКИ и Москвы, она же РУсь (RUS)
  scope :russian_countries, -> { where.not(id: [HORDE, LIVONIAN, SWEDEN, LITHUANIA, KAZAN, CRIMEA, VYATKA, RUS]) }

#Русские государства ЗА ИСКЛЮЧЕНИЕМ ВЯТКИ и Москвы, она же РУсь (RUS)
  scope :vyatka_free_countries, -> { where.not(id: [VYATKA, RUS]) }

  # Все государства, кроме указанного (текущего)
  scope :except_country, ->(country) { country.nil? ? all : where.not(id: country.id) }

  ############ Текущее государство ############

  # Текущее государство — то, за которое сейчас работают мастера.
  # Правило разрешения: session[:country_id] (ставит ApplicationController) →
  # «Русь», если она есть в базе → первое государство по id.
  def self.current
    Thread.current[:current_country] ||= resolve_current_country
  end

  def self.current=(country)
    Thread.current[:current_country] = country || resolve_current_country
  end

  # Приводит значение к объекту Country: принимает объект Country, его id
  # (встречалась устаревшая целочисленная константа Country::RUS) или nil.
  # Нужен там, где в модели приходит «государство» из старого кода или сидов.
  def self.resolve(value)
    return nil if value.nil?
    return value if value.is_a?(Country)

    find_by(id: value.to_i)
  end

  # Страна по умолчанию: «Русь», иначе первая по id (страховка для нестандартной базы)
  def self.resolve_current_country
    find_by(id: RUS) || order(:id).first
  end

  # «Русь» для парных операций (бонус «Третий Рим»); если её нет — текущее государство
  def self.rus_country
    find_by(id: RUS) || current
  end

  ############ Совет государства ############

  # Игроки этого государства на указанной должности (id или Job)
  def council_players(job)
    job_id = job.is_a?(Job) ? job.id : job.to_i
    players.joins(:jobs).where(jobs: { id: job_id })
  end
  alias council council_players

  # Идентификаторы держателей должности в этом государстве
  def council_player_ids(job)
    council_players(job).pluck(:id)
  end

  # Упорядоченный список должностей, занятых игроками этого государства
  def council_jobs
    job_ids = players.joins(:jobs).distinct.pluck('jobs.id').sort
    Job.where(id: job_ids).order(:id).map do |job|
      { id: job.id, name: job.name, job: job, players: council_players(job) }
    end
  end

  ############ Отношения (пары государств) ############

  # Элементы отношений пары (self, other) — оба конца пары
  def relation_items_with(other)
    return RelationItem.none if other.nil? || other.id == id

    RelationItem.where(country_id: id, partner_country_id: other.id)
                .or(RelationItem.where(country_id: other.id, partner_country_id: id))
  end

  # Значение отношений пары (self, other): сумма элементов обоих концов с кэпом ±REL_RANGE
  # плюс бонус технологии «Москва — Третий Рим» для пары с «Русью».
  def relations_with(other)
    if other.nil? || other.id == id
      Rails.logger.warn "[Country#relations_with] самопара проигнорирована (country_id=#{id})"
      return 0
    end

    cap_relations(relation_items_with(other).sum(&:value) + (third_rome_bonus_for?(other) ? self.class.moscow_third_rome_bonus : 0))
  end

  # Совместимый доступ: «отношения со страной-партнёром», по умолчанию — с текущим государством.
  # При игре за «Русь» это ровно прежнее поведение. Самопара читается суммой своих элементов
  # (как было до перехода на пары), чтобы поведение экранов при одной команде не изменилось.
  def relations(partner = nil)
    partner ||= Country.current
    return cap_relations(relation_items.sum(&:value)) if partner.nil? || partner.id == id

    relations_with(partner)
  end

  # Начисляется ли паре (self, other) бонус технологии «Москва — Третий Рим»
  def third_rome_bonus_for?(other)
    return false if other.nil? || other.id == id
    return false unless third_rome_pair?(other)
    return false unless third_rome_technology_open?

    true
  end

  def third_rome_pair?(other)
    ids = [id, other.id]
    return false unless ids.include?(RUS)

    (ids - [RUS]).all? { |other_id| THIRD_ROME_BONUS_COUNTRIES.include?(other_id) }
  end

  def third_rome_technology_open?
    technology = Technology.find_by(id: Technology::MOSCOW_THIRD_ROME)
    return false if technology.nil?

    technology.is_open(Country.rus_country) == 1
  end

  ############ Торговые очки и товарооборот пары ############

  def relation_points_for(partner = Country.current)
    stored = params&.dig('relation_points')
    # Скаляр — формат до перехода на пары: одна величина на государство (пара с «Русью»)
    return stored.to_i if stored.is_a?(Numeric) || stored.is_a?(String)

    key = self.class.partner_key(partner)
    return 0 if key.nil?

    (stored || {})[key].to_i
  end

  def add_relation_points(partner, n)
    write_partner_value('relation_points', partner) { |value| value + n.to_i }
  end

  def set_relation_points(partner, value)
    write_partner_value('relation_points', partner) { value.to_i }
  end

  def last_trade_turnover_for(partner = Country.current)
    stored = params&.dig('last_trade_turnover')
    return stored.to_i if stored.is_a?(Numeric) || stored.is_a?(String)

    key = self.class.partner_key(partner)
    return 0 if key.nil?

    (stored || {})[key].to_i
  end

  def set_last_trade_turnover(partner, value)
    write_partner_value('last_trade_turnover', partner) { value.to_i }
  end

  def self.partner_key(partner)
    return nil if partner.nil?

    partner_id = partner.is_a?(Country) ? partner.id : partner.to_i
    return nil if partner_id.nil? || partner_id.zero?

    partner_id.to_s
  end

  # Запись величины пары в params. Перенос скалярного (до пар) формата — при первой записи.
  def write_partner_value(key, partner)
    partner_key = self.class.partner_key(partner)
    return 0 if partner_key.nil?

    current = params || {}
    stored = current[key]
    hash = stored.is_a?(Hash) ? stored.dup : {}
    if !stored.is_a?(Hash) && !stored.nil? && partner_key == RUS.to_s
      # Скаляр относился к паре с «Русью» — переносим его в пару
      hash[partner_key] = stored.to_i
    end
    value = yield(hash[partner_key].to_i)
    hash[partner_key] = value
    current[key] = hash
    self.params = current
    save
    value
  end

  ############ Расходы государства ############

  def state_expenses_paid?(year = GameParameter.current_year)
    expenses = params&.dig('state_expenses')
    # Скалярный (до перехода) формат — флаг на всю игру
    return expenses == true && year.to_i == GameParameter.current_year.to_i if expenses == true || expenses == false

    (expenses || {})[year.to_s] == true
  end

  def pay_state_expenses(year = GameParameter.current_year)
    set_state_expenses(year, true)
  end

  def unpay_state_expenses(year = GameParameter.current_year)
    set_state_expenses(year, false)
  end

  def set_state_expenses(year, value)
    current = params || {}
    expenses = current['state_expenses']
    expenses = {} unless expenses.is_a?(Hash)
    expenses[year.to_s] = value
    current['state_expenses'] = expenses
    self.params = current
    save
  end

  # Аудит государства: пишем только значимые изменения params (расходы, эмбарго),
  # иначе аудит разрастается от любых правок params (торговые очки, пороги уровней).
  def should_audit?
    return true unless params_changed?

    state_expenses_changed? || embargo_params_changed?
  end

  def state_expenses_changed?
    return false unless params_changed?

    (params_was || {})['state_expenses'] != (params || {})['state_expenses']
  end

  def embargo_params_changed?
    return false unless params_changed?

    (params_was || {})['embargo'] != (params || {})['embargo']
  end

  def audit_comment
    return nil unless state_expenses_changed?

    old_expenses = (params_was || {})['state_expenses']
    new_expenses = (params || {})['state_expenses']
    return nil unless new_expenses.is_a?(Hash)

    old_expenses = {} unless old_expenses.is_a?(Hash)
    years = (old_expenses.keys | new_expenses.keys).sort_by(&:to_i)

    comments = years.map do |year|
      next if old_expenses[year] == new_expenses[year]

      if new_expenses[year] == true
        "Оплачены госрасходы за #{year} год (государство #{name})"
      elsif new_expenses[year] == false
        "Отменена оплата госрасходов за #{year} год (государство #{name})"
      end
    end.compact

    comments.presence&.join('; ')
  end

  ############ Прочее ############

  # Уровень товарооборота пары (self ↔ partner). Пороги берутся из params самого
  # государства, товарооборот считается с указанным партнёром (ТЗ № 1, § 15):
  # условия чек-листа вассалитета считаются по сюзерену чек-листа, а не по «Руси».
  def show_current_trade_level(partner = Country.current)
    # level_thresholds хранится в params
    levels = self.params&.dig("level_thresholds") || []
    return { current_level: 0, threshold: 0, to_next_level: 0 } if levels.empty?
    
    current_trade_turnover = self.calculate_trade_turnover(partner)[:trade_turnover] || 0
    
    # Находим текущий уровень: максимальный уровень, порог которого <= товарооборота
    current_level_info = levels.reverse.find { |lev| lev["threshold"].to_i <= current_trade_turnover }
    
    # Если не найден (товарооборот меньше первого порога), берём первый уровень
    if current_level_info.nil?
      current_level_info = levels.first
      current_level_number = 0
      next_level_info = levels.first
    else
      current_level_number = current_level_info["level"]
      # Находим следующий уровень
      next_level_info = levels.find { |lev| lev["level"] > current_level_number }
      
      # Если следующего уровня нет (достигнут максимум), используем текущий
      next_level_info ||= current_level_info
    end
    
    to_next_level = next_level_info["threshold"].to_i - current_trade_turnover
    to_next_level = 0 if to_next_level < 0
    
    return {
      current_level: current_level_number,
      threshold: next_level_info["threshold"],
      to_next_level: to_next_level
    }
  end

  def self.show_trade_turnover
    foreign_countries = Country.foreign_countries
    overall_trade_turnover = foreign_countries.map do |f_c|
      car_data = f_c.calculate_trade_turnover
      {country_id:    f_c.id,
      country_name:   f_c.name,
      short_name:     f_c.short_name || f_c.name,
      flag_image_name: f_c.flag_image_name,
      trade_turnover: car_data[:trade_turnover],
      car_count:      car_data[:num_of_car],
      relations:      f_c.relations}
    end

    # Add Vyatka trade turnover separately (always show, even with 0 caravans)
    vyatka_data = calculate_vyatka_trade_turnover
    overall_trade_turnover << {
      country_id: Country::VYATKA,
      country_name: 'Вятка',
      short_name: 'Вятка',
      flag_image_name: 'vyatka',
      trade_turnover: vyatka_data[:trade_turnover],
      car_count: vyatka_data[:num_of_car],
      relations: nil
    }

    return overall_trade_turnover
  end

  def calculate_trade_turnover(partner = Country.current)
    # Если установлен ручной товарооборот, используем его
    manual_turnover = self.params&.dig('manual_trade_turnover')
    if manual_turnover.present? && manual_turnover.to_i > 0
      caravans = caravans_for(partner)
      return {trade_turnover: manual_turnover.to_i, num_of_car: caravans.count}
    end

    caravans = caravans_for(partner)
    trade_turnover = 0
    # Исключаем караваны через Вятку и ограбленные караваны из расчета товарооборота
    caravans.each {|car| trade_turnover += (car.gold_export || 0) + (car.gold_import || 0) unless car.via_vyatka == true || car.is_robbed == true}
    return {trade_turnover: trade_turnover || 0, num_of_car: caravans.count}
  end

  # Караваны пары (self ↔ partner). Караваны государства = пришедшие в него
  # (caravans.country_id — страна-получатель), источник определяется страной гильдии.
  # Гильдии без государства и караваны без гильдии — наследие до перехода на несколько
  # команд: считаются в паре с «Русью», как было до миграции данных.
  def caravans_for(partner = Country.current)
    return caravans if partner.nil? || partner.id == id

    guild_ids = Guild.where(country_id: partner.id).pluck(:id)
    if partner.id == RUS
      legacy_guild_ids = Guild.where(country_id: nil).pluck(:id)
      ids = (guild_ids + legacy_guild_ids).presence || [-1]
      caravans.where("caravans.guild_id IS NULL OR caravans.guild_id IN (?)", ids)
    else
      caravans.where(guild_id: guild_ids)
    end
  end

  def self.calculate_vyatka_trade_turnover
    # Считаем все караваны прошедшие через Вятку
    vyatka_caravans = Caravan.where(via_vyatka: true)
    trade_turnover = vyatka_caravans.sum { |car| (car.gold_export || 0) + (car.gold_import || 0) }
    return {trade_turnover: trade_turnover || 0, num_of_car: vyatka_caravans.count}
  end

  def embargo #1 - эмбарго есть, 0 - эмбарго нет
    params['embargo']
  end

  # Торгует ли государство на рынке: у него есть хотя бы один товар с ценой.
  # Такие товары видны на вкладке «Рынок» (Resource.show_prices), поэтому признак
  # совпадает с тем, что видит мастер: у Руси и русских княжеств своих товаров нет,
  # торгуют только Орда, Ливония, Швеция, Литва, Казань и Крым.
  def trades_on_market?
    resources.any? { |resource| Resource.priced?(resource) }
  end

  def set_embargo
    return false if params['embargo'].nil?
    self.params['embargo'] = params['embargo'] == 0 ? 1 : 0
    self.save
  end

  # Кнопка «улучшить отношения через торговлю»: тратим очки пары и улучшаем отношения
  def improve_relations_via_trade(force: false, partner: Country.current)
    relation_points = relation_points_for(partner)

    # Проверяем, что есть relation_points для траты
    if relation_points < 1
      return { success: false, error: 'Недостаточно торговых очков (relation_points)' }
    end

    # Уменьшаем relation_points на 1
    add_relation_points(partner, -1)

    # Улучшаем отношения на 1
    result = change_relations(1, self, "Улучшение через торговлю", partner: partner, force: force)

    # Проверяем, было ли предупреждение
    warning = nil
    if result.is_a?(Hash) && result[:warning]
      warning = result[:warning]
    elsif result.is_a?(String)
      # Если вернулась ошибка (не force режим)
      return { success: false, error: result }
    end

    response = { success: true, new_relations: relations(partner), relation_points_left: relation_points_for(partner) }
    response[:warning] = warning if warning
    response
  rescue => e
    { success: false, error: e.message }
  end

  # Award relation points when trade volume level increases
  # Returns hash with success status and points awarded
  def check_and_award_trade_level_points(previous_trade_turnover: nil, partner: Country.current)
    levels = self.params&.dig("level_thresholds") || []
    return { success: false, error: 'No trade levels configured' } if levels.empty?
    
    current_trade_turnover = self.calculate_trade_turnover(partner)[:trade_turnover] || 0
    
    # Find current level
    current_level_info = levels.reverse.find { |lev| lev["threshold"].to_i <= current_trade_turnover }
    current_level_number = current_level_info ? current_level_info["level"] : 0
    
    # If we have previous turnover, calculate previous level
    if previous_trade_turnover.nil?
      # No previous data, just store current level for future comparison
      set_last_trade_turnover(partner, current_trade_turnover)
      return { success: false, message: 'Initial trade level recorded', current_level: current_level_number }
    end
    
    previous_level_info = levels.reverse.find { |lev| lev["threshold"].to_i <= previous_trade_turnover }
    previous_level_number = previous_level_info ? previous_level_info["level"] : 0
    
    # Check if level increased
    level_increase = current_level_number - previous_level_number
    
    if level_increase > 0
      # Check if relations are already at or above the maximum for earning trade points
      max_relations = GameParameter.get_max_relations_for_trade_points
      current_relations = relations(partner)
      
      if current_relations >= max_relations
        # Don't award points if relations are at or above the limit
        # But still update last_trade_turnover for future tracking
        set_last_trade_turnover(partner, current_trade_turnover)

        return {
          success: false,
          message: "Relations too high (#{current_relations} >= #{max_relations}). No points awarded.",
          current_level: current_level_number,
          relations: current_relations,
          max_relations: max_relations
        }
      end

      # Get existing relation points
      existing_points = relation_points_for(partner)

      # Calculate maximum points that can be awarded (don't exceed relations cap)
      # Consider both existing points and the gap to max relations
      max_points_allowed = max_relations - current_relations
      max_total_points = existing_points + level_increase

      # Only award points if the total won't exceed the gap
      if max_total_points > max_points_allowed
        # Don't award any points if total would exceed the limit
        set_last_trade_turnover(partner, current_trade_turnover)

        return {
          success: false,
          message: "Adding #{level_increase} points would exceed maximum (existing: #{existing_points}, gap: #{max_points_allowed}). No points awarded.",
          current_level: current_level_number,
          relations: current_relations,
          max_relations: max_relations,
          existing_points: existing_points,
          points_would_exceed: level_increase
        }
      end

      # Award full points
      points_to_award = level_increase
      total_points = add_relation_points(partner, points_to_award)
      set_last_trade_turnover(partner, current_trade_turnover)

      {
        success: true,
        points_awarded: points_to_award,
        previous_level: previous_level_number,
        current_level: current_level_number,
        total_relation_points: total_points
      }
    else
      # No level increase, just update stored turnover
      set_last_trade_turnover(partner, current_trade_turnover)
      { success: false, message: 'No level increase', current_level: current_level_number }
    end
  rescue => e
    { success: false, error: e.message }
  end

# вынести на фронт

  def change_relations(count, entity, comment = nil, partner: Country.current, force: false)
    count = count.to_i
    partner ||= Country.current
    rel = relations(partner)
    
    # Проверяем эффект запрета улучшения отношений
    # Если force == true (ручная правка мастера), пропускаем проверку, но помечаем предупреждение
    if GameParameter.any_lingering_effects?("no_relation_improvement", GameParameter.current_year)
      if count > 0
        if force
          # Для ручных правок мастера - разрешаем, но возвращаем предупреждение
          # Продолжаем выполнение ниже
        else
          return "Нельзя улучшить отношения в этом году"
        end
      end
    end  

    # Проверяем эффект "отношения не падают ниже нейтральных" для ЭТОЙ страны
    if GameParameter.any_lingering_effects?("non_negative_relations", GameParameter.current_year, self.name)
       # ПРАВИЛЬНАЯ формула: rel + count (count может быть отрицательным при ухудшении)
       if rel + count < 0
        if force
          # Для ручных правок мастера - разрешаем, но возвращаем предупреждение
          # Продолжаем выполнение ниже
        else
         return "Нельзя - отношения с #{self.name} не могут падать ниже нейтральных (эффект 'Передача армии')"
        end
       end
    end 
    
    rel = relations(partner)
    r = rel + count
    
    # Проверяем, было ли предупреждение о блокировке улучшения
    warning_message = nil
    if force && count > 0 && GameParameter.any_lingering_effects?("no_relation_improvement", GameParameter.current_year)
      warning_message = "⚠️ Внимание: Отношения не были улучшены из-за эффекта 'Поддержать экспорт', но изменение применено вручную."
    end
    
    if entity.is_a?(PoliticalAction)
      comment = entity.political_action_type&.name
    elsif comment.blank?
      comment = entity.try(:name)
    end
    RelationItem.add(
      r.abs > REL_RANGE ? ((r / r.abs) * (count.abs - (r.abs - REL_RANGE))) : count,
      comment,
      self,
      entity,
      partner
    )
    
    # Возвращаем предупреждение, если оно было
    return { warning: warning_message } if warning_message
    
    return true
  end

  def cap_relations(value)
    value = value.to_i
    value.abs > REL_RANGE ? (value / value.abs) * [value.abs, REL_RANGE].min : value
  end

  def capture(region, how) #1 - войной, 0 - миром
    if region.country_id != self.id
     region.country_id = self.id
      if how.to_i == BY_WAR
        PublicOrderItem.add(MILITARILY, "Присоединение войной #{region.name}", region, nil)
      elsif how.to_i == BY_DIPLOMACY
        PublicOrderItem.add(PEACEFULLY, "Присоединение миром #{region.name}", region, nil)
      end

      council_players(Job::GRAND_PRINCE).each do |player|
        player.modify_influence(Job::GRAND_PRINCE_BONUS, "Бонус за присоединение миром #{region.name}", self)
      end

      region.save
    end
  end

  # Страна присоединяется к текущему государству миром: регионы переходят текущему
  # государству, бонус получает совет текущего государства.
  def join_peace(receiver = Country.current)
    receiver ||= Country.current
    return { result: false, msg: 'Текущее государство не определено' } if receiver.nil?

    if regions.any? { |r| r.country_id != receiver.id }
      regions.each { |r| receiver.capture(r, BY_DIPLOMACY) }
      receiver.council_players(Job::POSOL).each do |player|
        player.modify_influence(Job::POSOL_BONUS, "Бонус за присоединение миром #{self.name}", self)
      end
    end

    { result: true, msg: 'Страна присоединена' }
  end
end
