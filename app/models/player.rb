class Player < ApplicationRecord
  # params:
  # influence (integer) - Влияние
  # contraband ([]) - Контрабанда
  audited

  belongs_to :human, optional: true
  belongs_to :player_type, optional: true
  belongs_to :family, optional: true
  has_and_belongs_to_many :jobs
  belongs_to :guild, optional: true

  has_many :plants, :as => :economic_subject,
           :inverse_of => :economic_subject
  has_many :settlements
  has_many :regions
  has_many :armies, :as => :owner,
           :inverse_of => :owner
  has_many :credits
  has_many :political_actions
  has_many :influence_items
  has_many :income_items

  before_validation :generate_identificator_if_blank

  validates :name, presence: { message: "Поле Имя должно быть заполнено" }
  validates :identificator, presence: true, uniqueness: true
  
  # Получение текущего игрока из сессии
  def self.current
    return nil unless Thread.current[:current_player_id]
    
    @current_player ||= find_by(id: Thread.current[:current_player_id])
  end
  
  # Установка текущего игрока в поток
  def self.current=(player)
    if player
      Thread.current[:current_player_id] = player.id
      @current_player = player
    else
      Thread.current[:current_player_id] = nil
      @current_player = nil
    end
  end
  
  # Генерация уникального идентификатора
  # Используется в seeds и при автоматической генерации
  def self.generate_identificator(name, human_name = nil, family_name = nil, job_name = nil, index = nil)
    base_string = "#{name}_#{human_name}_#{family_name}_#{job_name}"
    base_string += "_#{index}" if index
    hash = Digest::SHA256.hexdigest(base_string)[0..15].upcase
    hash
  end

  ####MOBILE##########

  ###производство

  def produce_at_plant(plant_id, hashed_resources = [])

    # Валидация входных данных
    raise ArgumentError, "plant_id is required" if plant_id.blank?
    raise ArgumentError, "hashed_resources must be an array" unless hashed_resources.is_a?(Array)
    
    # Нормализация данных
    normalized_res = hashed_resources.map { |res| res.transform_keys(&:to_sym) }
    
    # Проверяем, что у игрока достаточно ресурсов
    validate_resources_availability(normalized_res)
    
    # Находим предприятие игрока
    plant = self.plants.find(plant_id)
    raise "Предприятие не найдено или не принадлежит игроку" unless plant
    
    # Проверяем, что предприятие не производило в текущем году
    current_year = GameParameter.current_year
    if plant.params["produced"].include?(current_year)
      raise "Предприятие уже производило в текущем году"
    end
    
    # Проверяем, что у предприятия есть уровень
    raise "У предприятия не указан уровень" unless plant.plant_level
    
    # Вычитаем ресурсы у игрока
    subtract_resources_from_sender(normalized_res)
    
    # Производим на предприятии
    result = plant.plant_level.feed_to_plant!(normalized_res, 'from')
    
    # Добавляем произведенные ресурсы игроку
    add_resources_to_recipient(self, result[:to])
    
    # Отмечаем, что предприятие произвело в текущем году
    plant.params["produced"] << current_year
    plant.save!
    
    # Сохраняем изменения игрока
    self.save!
    
    result
  rescue => e
    Rails.logger.error "Production error for player #{self.id}, plant #{plant_id}: #{e.message}"
    raise e
  end


  ###рынок
  def show_player_gold
    return {:identificator=>"gold", :count=> 0} if self.resources.nil?
    normalized_res = self.resources.map { |res| res.transform_keys(&:to_sym) }
    gold = normalized_res.find {|g| g[:identificator] == "gold"}
    gold_res = gold.empty? ? {:identificator=>"gold", :count=> 0} : gold
    return gold_res
  end

  def buy_and_sell_res(sold_resources = [], purchased_resources = [])
    normalized_sold_resources       = sold_resources.map      { |res| res.transform_keys(&:to_sym) }
    normalized_purchased_resources  = purchased_resources.map { |res| res.transform_keys(&:to_sym) }
    subtract_resources_from_sender(normalized_sold_resources)
    add_resources_to_recipient(self, normalized_purchased_resources)
    self.save!
  end
  
  # def buy_and_sell_res(country_id, res_pl_sells = [], res_pl_buys = [])
  #   # Валидация входных данных
  #   raise ArgumentError, "country_id is required" if country_id.blank?
  #   raise ArgumentError, "res_pl_sells must be an array" unless res_pl_sells.is_a?(Array)
  #   raise ArgumentError, "res_pl_buys must be an array" unless res_pl_buys.is_a?(Array)
    
  #   # Нормализация данных
  #   normalized_res_pl_sells = res_pl_sells.map { |res| res.transform_keys(&:to_sym) }
  #   normalized_res_pl_buys = res_pl_buys.map { |res| res.transform_keys(&:to_sym) }

  #   # Проверяем, что у игрока достаточно ресурсов для продажи
  #   validate_resources_availability(normalized_res_pl_sells)
    
  #   # Проверяем, что у игрока достаточно золота для покупки
  #   validate_gold_availability(normalized_res_pl_buys, country_id)

  #   # Выполняем торговлю через Resource.send_caravan (получаем результат)
  #   result = Resource.send_caravan(country_id, normalized_res_pl_sells, normalized_res_pl_buys)
    
  #   # Применяем изменения к ресурсам игрока
  #   apply_trade_changes(normalized_res_pl_sells, normalized_res_pl_buys, result[:res_to_player])
    
  #   # Сохраняем изменения
  #   self.save!
    
  #   result
  # rescue => e
  #   Rails.logger.error "Trade error for player #{self.id}: #{e.message}"
  #   raise e
  # end

  def exchange_resources(with_whom, hashed_resources)
    # Приводим ключи к символам без изменения оригинальных данных
    normalized_resources = hashed_resources.map { |res| res.transform_keys(&:to_sym) }
    
    # Проверяем, что у текущего игрока достаточно ресурсов
    validate_resources_availability(normalized_resources)

    counterpart = Player.find_by(identificator: with_whom)
    raise "Игрок не найден" unless counterpart

    # Вычитаем ресурсы у текущего игрока
    subtract_resources_from_sender(normalized_resources)

    # Добавляем ресурсы контрагенту
    add_resources_to_recipient(counterpart, normalized_resources)

    # Сохраняем изменения
    self.save!
    counterpart.save!
  end

  def validate_resources_availability(resources)
    resources.each do |res|
      available = available_resources.find { |avail| avail[:identificator] == res[:identificator] }
      unless available && available[:count] >= res[:count]
        raise "Недостаточно ресурсов #{res[:identificator]}"
      end
    end
  end

  def subtract_resources_from_sender(resources)
    resources.each do |res|
      available_res = self.resources.find { |r| r["identificator"] == res[:identificator] }
      if available_res
        available_res["count"] -= res[:count]
        # Удаляем ресурс, если его количество стало 0 или меньше
        if available_res["count"] <= 0
          self.resources.delete(available_res)
        end
      end
    end
  end

  def add_resources_to_recipient(recipient, resources)
    if recipient.resources == nil
      recipient.resources  = resources
    else
      normalized_resources = resources.map { |res| res.transform_keys(&:to_sym) }

      normalized_resources.each do |res|
        # Ищем ресурс напрямую в recipient.resources
      recipient_res = recipient.resources.find { |r| r["identificator"] == res[:identificator] }
      if recipient_res
          # Изменяем напрямую в оригинальном массиве
        recipient_res["count"] += res[:count]
      else
        # Если у контрагента нет такого ресурса, добавляем его
          recipient.resources << {"name" => res[:name], "identificator" => res[:identificator], "count" => res[:count] }
        end
      end
    end
  end

  # Вспомогательный метод для получения доступных ресурсов
  def available_resources
    self.resources.map { |res| res.transform_keys(&:to_sym) }
  end

  def own_count
    settlements.count + regions.count
  end

  def my_buildings
    (settlements.map{|s| s.buildings.map{|b| b.building_level}}.flatten + 
    regions.map{|r| r.capital.buildings.map{|b| b.building_level}}.flatten).
      sort_by{|bl| bl.building_type_id}.
      map.with_index do |bl, idx|
      {
        building_type_id: bl.building_type_id,
        building_type: bl.building_type,
        level: bl.level,
        index: idx
      }
    end
  end

  def income
    base = income_base
    (base + income_items.sum(:value).to_i)
  end

  def income_base
    year = GameParameter.current_year

    # Проверяем эффект увеличенного дохода от торговли для текущего года
    added_income =
      if self.job_ids.include?(Job::GRAND_PRINCE) &&
         GameParameter.any_lingering_effects?("increased_trade_revenue", year - 1)
        Caravan.count_caravan_revenue
      else
        0
      end

    sum = 0
    sum += added_income

    if job_ids.include?(Job::METROPOLITAN)
      church_params = Building.joins({ settlement: :region }, :building_level)
                             .where(building_levels: { building_type_id: BuildingType::RELIGIOUS })
                             .where(regions: { country_id: Country::RUS })
                             .select('building_levels.params')
      sum += church_params.map { |p| p.params['metropolitan_income'].to_i }.sum
    end

    st_george_bonus = Technology.find(Technology::ST_GEORGE_DAY).is_open == 1 ? 1000 : 0
    sum + self.settlements.sum { |s| s.income + st_george_bonus }
  end

  def income_breakdown
    year = GameParameter.current_year
    st_george_bonus = Technology.find(Technology::ST_GEORGE_DAY).is_open == 1 ? 1000 : 0

    settlements_data = self.settlements.includes(:settlement_type, buildings: { building_level: :building_type }).map do |s|
      type_income = s.settlement_type&.params&.dig("income").to_i

      buildings = s.buildings.map do |b|
        {
          building_id: b.id,
          name: b.building_level&.name,
          type: b.building_level&.building_type&.name,
          level: b.building_level&.level,
          income: b.income.to_i
        }
      end

      markets_income = buildings.select { |b| b[:type].to_s == "Рынок" }.sum { |b| b[:income].to_i }
      buildings_sum = buildings.sum { |b| b[:income].to_i }
      total = type_income + buildings_sum + st_george_bonus

      {
        settlement_id: s.id,
        name: s.name,
        type_income: type_income,
        markets_income: markets_income,
        buildings_sum: buildings_sum,
        st_george_bonus: st_george_bonus,
        total: total,
        buildings: buildings.sort_by { |b| [b[:type].to_s, b[:level].to_i, b[:name].to_s] }
      }
    end

    settlements_total = settlements_data.sum { |s| s[:total].to_i }

    trade_bonus =
      if self.job_ids.include?(Job::GRAND_PRINCE) &&
         GameParameter.any_lingering_effects?("increased_trade_revenue", year - 1)
        Caravan.count_caravan_revenue
      else
        0
      end

    metropolitan_bonus = 0
    if job_ids.include?(Job::METROPOLITAN)
      church_params = Building.joins({ settlement: :region }, :building_level)
                             .where(building_levels: { building_type_id: BuildingType::RELIGIOUS })
                             .where(regions: { country_id: Country::RUS })
                             .select('building_levels.params')
      metropolitan_bonus = church_params.map { |p| p.params['metropolitan_income'].to_i }.sum
    end

    base_total = settlements_total + trade_bonus + metropolitan_bonus

    items = income_items.order(created_at: :desc).map do |ii|
      {
        id: ii.id,
        value: ii.value.to_i,
        comment: ii.comment,
        year: ii.year,
        created_at: ii.created_at
      }
    end

    manual_sum = items.sum { |ii| ii[:value].to_i }

    {
      player_id: id,
      player_name: name,
      year: year,
      base_total: base_total,
      manual_sum: manual_sum,
      total: base_total + manual_sum,
      components: {
        settlements_total: settlements_total,
        trade_bonus: trade_bonus,
        metropolitan_bonus: metropolitan_bonus
      },
      settlements: settlements_data.sort_by { |s| s[:name].to_s },
      income_items: items
    }
  end

  def modify_income(value, comment, entity = nil)
    IncomeItem.add(value, comment, self, entity)
  end

  def player_military_outlays
    cost = 0
    self.armies.each do |army|
      cost += army.troops.count * Troop::RENEWAL_COST
    end
    cost
  end

  def influence_buildings
    sum = 0
    if job_ids.include?(Job::METROPOLITAN)
      # Получаем церкви, которые были оплачены в предыдущем году ИЛИ созданы в текущем году
      previous_year = GameParameter.current_year - 1
      current_year = GameParameter.current_year
      
      church_buildings = Building.joins({settlement: :region}, :building_level).
        where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
        where(regions: {country_id: Country::RUS}).
        where("buildings.params::jsonb->'paid' @> ?::jsonb OR buildings.params::jsonb->'first_year' = ?::jsonb", 
              [previous_year].to_json, current_year.to_json)
      
      sum += church_buildings.joins(:building_level).sum do |building|
        building.building_level.params['metropolitan_influence'].to_i
      end
    end
    def_params = Building.joins({settlement: :region}, :building_level).
      where(building_levels: {building_type_id: BuildingType::DEFENCE}).
      where(regions: {country_id: Country::RUS}).
      where(settlements: {player_id: self.id}).
      select('building_levels.params')
    sum + def_params.map{|p| p.params['influence'].to_i}.sum
  end

  def influence
    influence_buildings + influence_items.sum{|ii| ii.value.to_i}
  end

  def give_credit(plant_ids)
    if check_credit(plant_ids)
      plants = Plant.where(id: plant_ids)
      credit_deposit = 0
      credit_term = GameParameter.find_by(identificator: "credit_term")&.value.to_i
      credit_size = GameParameter.find_by(identificator: "credit_size")&.value.to_f / 100
      start_year = GameParameter.find_by(identificator: "current_year")&.value.to_i
      plants.each { |p| credit_deposit += p.plant_level.deposit }
      credit_sum = credit_deposit + ((credit_deposit * credit_size) * credit_term).round if credit_deposit.present?
      credit_new = self.credits.create(sum: credit_sum, deposit: credit_deposit, procent: credit_size, duration: credit_term, start_year: start_year)
      new_credit_id = credit_new.id
      plants_with_credit = plants.update(credit_id: new_credit_id)
      final_hash = {
        credit_deposit: credit_deposit, 
        credit_term: credit_term,
        credit_sum: credit_sum
      }
      return {result: final_hash, msg: "Кредит выдан"}
    else
      return {result: false, msg: "Кредит не выдан, одно или несколько предприятий уже находятся в залоге"}
    end
  end

  def add_army(army_size_id, region_id)
    self.armies.create(army_size_id: army_size_id, region_id: region_id)
  end

  def run_political_action(political_action_type_id, year, success, options)
    pat = PoliticalActionType.find_by_id(political_action_type_id)
    result = pat.execute(success, options)
    self.political_actions.create(year: year, success: success, params: result, political_action_type_id: political_action_type_id)
  end

  def self.all_contrabandists
    Player.all.select{|p| p.params["contraband"]&.include?(GameParameter.current_year)}
  end

  def modify_influence(value, comment, entity) #Изменить влияние игрока
    InfluenceItem.add(value, comment, self, entity)
  end

  private

  # Генерация identificator, если он не заполнен
  def generate_identificator_if_blank
    return if identificator.present?
    
    # Используем единый метод генерации
    timestamp = Time.now.to_i
    base_id = self.class.generate_identificator(name, timestamp.to_s)
    
    # Проверяем уникальность и добавляем суффикс, если нужно
    index = 1
    self.identificator = base_id
    while Player.exists?(identificator: self.identificator)
      self.identificator = self.class.generate_identificator(name, timestamp.to_s, nil, nil, index)
      index += 1
    end
  end

  # Проверка достаточности золота для покупки ресурсов
  def validate_gold_availability(res_pl_buys, country_id)
    return if res_pl_buys.empty?
    
    # Рассчитываем стоимость покупки
    total_cost = 0
    res_pl_buys.each do |res|
      next unless res[:count] && res[:count] > 0
      
      resource_obj = Resource.find_by(identificator: res[:identificator])
      next unless resource_obj
      
      cost_result = Resource.calculate_cost("sale", res[:count], resource_obj)
      next unless cost_result[:cost]
      
      total_cost += cost_result[:cost]
    end
    
    # Проверяем, что у игрока достаточно золота
    current_gold = show_player_gold[:count] || 0
    if current_gold < total_cost
      raise "Недостаточно золота. Требуется: #{total_cost}, доступно: #{current_gold}"
    end
  end

  # Применение изменений к ресурсам игрока после торговли
  def apply_trade_changes(res_pl_sells, res_pl_buys, trade_result)
    # 1. Вычитаем проданные ресурсы у игрока
    res_pl_sells.each do |res|
      next unless res[:count] && res[:count] > 0
      
      current_res = self.resources.find { |r| r["identificator"] == res[:identificator] }
      if current_res
        current_res["count"] -= res[:count]
        # Удаляем ресурс, если количество стало 0 или отрицательным
        if current_res["count"] <= 0
          self.resources.delete(current_res)
        end
      end
    end
    
    # 2. Добавляем купленные ресурсы игроку
    res_pl_buys.each do |res|
      next unless res[:count] && res[:count] > 0
      
      current_res = self.resources.find { |r| r["identificator"] == res[:identificator] }
      if current_res
        current_res["count"] += res[:count]
      else
        # Добавляем новый ресурс
        self.resources << { "identificator" => res[:identificator], "count" => res[:count] }
      end
    end
    
    # 3. Применяем итоговое изменение золота из результата торговли
    trade_result.each do |resource|
      next unless resource[:identificator] == "gold"
      
      current_gold = self.resources.find { |r| r["identificator"] == "gold" }
      if current_gold
        current_gold["count"] += resource[:count]
        # Удаляем золото, если количество стало 0 или отрицательным
        if current_gold["count"] <= 0
          self.resources.delete(current_gold)
        end
      else
        # Добавляем золото только если количество положительное
        if resource[:count] > 0
          self.resources << { "identificator" => "gold", "count" => resource[:count] }
        end
      end
    end
    
    # 4. Финальная проверка: убеждаемся, что золото не стало отрицательным
    gold_res = self.resources.find { |r| r["identificator"] == "gold" }
    if gold_res && gold_res["count"] < 0
      raise "Ошибка: золото не может быть отрицательным. Текущее значение: #{gold_res["count"]}"
    end
  end

  #####################

  def check_credit(plant_ids)
    plants = Plant.where(id: plant_ids)
    plants.all?{|p| p.credit_id.blank?}
  end
end

