class AuditsController < ApplicationController
  def index
    # Загружаем аудиты с разными ассоциациями для разных типов auditable
    @audits = Audited::Audit.includes(
      auditable: [
        :job, 
        :political_action_type, 
        :player, 
        :entity, 
        :settlement, 
        :building_level,
        :technology,
        :attacker_army,
        :defender_army,
        :winner_army,
        :troop_type,
        :army,
        :owner,
        building_level: :building_type,
        army: [:settlement, :owner],
        troop_type: []
      ]
    ).last(50).reverse
    
    # Загружаем просмотренные события для текущего пользователя
    if current_user
      @viewed_audit_ids = current_user.viewed_audits.pluck(:audit_id)
    else
      @viewed_audit_ids = []
    end
  end
  
  def mark_as_viewed
    if current_user
      audit_id = params[:audit_id]
      
      if audit_id
        # Отмечаем конкретное событие как просмотренное
        audit = Audited::Audit.find_by(id: audit_id)
        if audit
          # Создаем или обновляем запись о просмотре конкретного события
          viewed_audit = current_user.viewed_audits.find_or_initialize_by(audit_id: audit_id)
          viewed_audit.viewed_at = Time.current
          viewed_audit.save
        end
      else
        # Если ID не передан, обновляем время последнего просмотра (для совместимости)
        current_user.update(last_audit_show: Time.current)
      end
      
      render json: { status: 'success' }
    else
      render json: { status: 'error', message: 'User not found' }, status: 401
    end
  end

  def mark_all_as_viewed
    if current_user
      # Получаем все аудиты, которые еще не просмотрены
      unviewed_audits = Audited::Audit.where.not(id: current_user.viewed_audits.pluck(:audit_id))
      
      # Создаем записи для всех непросмотренных событий
      viewed_audits_data = unviewed_audits.map do |audit|
        {
          user_id: current_user.id,
          audit_id: audit.id,
          viewed_at: Time.current,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
      
      # Массовая вставка для производительности
      ViewedAudit.insert_all(viewed_audits_data) if viewed_audits_data.any?
      
      render json: { 
        status: 'success', 
        marked_count: viewed_audits_data.length 
      }
    else
      render json: { status: 'error', message: 'User not found' }, status: 401
    end
  end

  def yearly_stats
    # Получаем все аудиты с группировкой по году и категории
    audits = Audited::Audit.includes(:auditable)
      .where.not(auditable_type: nil)
      .order(:created_at)
    
    # Группируем по году
    yearly_data = {}
    
    audits.each do |audit|
      # Получаем год из auditable объекта или используем текущий год
      year = get_audit_year(audit)
      category = get_audit_category(audit)
      
      yearly_data[year] ||= {}
      yearly_data[year][category] ||= 0
      yearly_data[year][category] += 1
    end
    
    render json: yearly_data
  end

  def detailed_yearly_stats
    year = params[:year]&.to_i || GameParameter.current_year
    
    # Получаем все аудиты
    audits = Audited::Audit.includes(:auditable)
      .where.not(auditable_type: nil)

    # Фильтруем по игровому году для объектов с полем year
    audits = audits.select do |audit|
      if audit.auditable&.respond_to?(:year)
        audit.auditable.year == year
      else
        # Для объектов без поля year используем текущий игровой год
        GameParameter.current_year == year
      end
    end
    
    detailed_stats = {
      year: year
    }
    
    # Добавляем только те категории, где что-то произошло
    army_payments = get_army_payment_stats(audits)
    detailed_stats[:army_payments] = army_payments if army_payments[:paid_count] > 0
    
    state_expenses = get_state_expenses_stats(audits)
    detailed_stats[:state_expenses] = state_expenses if state_expenses[:paid] || state_expenses[:unpaid]
    
    region_annexations = get_region_annexation_stats(audits)
    detailed_stats[:region_annexations] = region_annexations if region_annexations[:total_annexations] > 0
    
    region_transfers = get_region_transfer_stats(audits)
    detailed_stats[:region_transfers] = region_transfers if region_transfers[:total_transfers] > 0
    
    battles = get_battle_stats(audits)
    detailed_stats[:battles] = battles if battles[:total_battles] > 0
    
    job_changes = get_job_changes_stats(audits)
    detailed_stats[:job_changes] = job_changes if job_changes[:total_changes] > 0
    
    noble_actions = get_noble_actions_stats(audits)
    detailed_stats[:noble_actions] = noble_actions if (noble_actions[:total_successful] > 0) || (noble_actions[:total_failed] > 0)
    
    buildings = get_building_stats(audits)
    detailed_stats[:buildings] = buildings if (buildings[:total_created] > 0) || (buildings[:total_updated] > 0) || (buildings[:total_destroyed] > 0)
    
    public_order_changes = get_public_order_stats(audits)
    detailed_stats[:public_order_changes] = public_order_changes if public_order_changes[:total_changes] > 0
    
    technologies = get_technology_stats(audits)
    detailed_stats[:technologies] = technologies if (technologies[:total_opened] > 0) || (technologies[:total_closed] > 0)
    
    # Изменения отношений
    relations = get_relations_stats(audits)
    detailed_stats[:relations] = relations if relations[:total_changes] > 0
    
    # Изменения эмбарго
    embargo_changes = get_embargo_stats(audits)
    detailed_stats[:embargo_changes] = embargo_changes if embargo_changes[:total_changes] > 0
    
    render json: detailed_stats
  end

  def get_relations_stats(audits)
    relation_audits = audits.select { |a| a.auditable_type == 'RelationItem' }
    
    # Группируем по странам
    by_country = {}
    total_changes = 0
    
    relation_audits.each do |audit|
      country = audit.auditable&.country
      next unless country
      
      country_name = country.name
      by_country[country_name] ||= {
        country_name: country_name,
        changes: [],
        total_value: 0
      }
      
      value = audit.auditable&.value || 0
      comment = audit.auditable&.comment || ''
      year = audit.auditable&.year || 'неизвестный год'
      
      by_country[country_name][:changes] << {
        value: value,
        comment: comment,
        year: year
      }
      by_country[country_name][:total_value] += value
      total_changes += 1
    end
    
    {
      total_changes: total_changes,
      by_country: by_country.values
    }
  end

  def get_embargo_stats(audits)
    country_audits = audits.select { |a| a.auditable_type == 'Country' && a.action == 'update' }
    
    embargo_changes = []
    
    country_audits.each do |audit|
      changes = audit.audited_changes
      next unless changes&.dig('params')
      
      old_params = changes['params'][0]
      new_params = changes['params'][1]
      old_embargo = old_params&.dig('embargo')
      new_embargo = new_params&.dig('embargo')
      
      next unless old_embargo != new_embargo
      
      country_name = audit.auditable&.name || "Неизвестная страна"
      
        if old_embargo == 0 && new_embargo == 1
          embargo_changes << {
            country_name: country_name,
            action: 'введено',
            year: get_audit_year(audit)
          }
        elsif old_embargo == 1 && new_embargo == 0
          embargo_changes << {
            country_name: country_name,
            action: 'снято',
            year: get_audit_year(audit)
          }
      end
    end
    
    {
      total_changes: embargo_changes.count,
      changes: embargo_changes
    }
  end

  private

  def get_audit_year(audit)
    # Пытаемся получить год из auditable объекта
    if audit.auditable&.respond_to?(:year)
      audit.auditable.year
    else
      # Fallback на текущий год игры
      GameParameter.current_year
    end
  end

  def get_audit_category(audit)
    case audit.auditable_type
    when 'PoliticalAction'
      action_name = audit.action.downcase
      if ['sedition', 'charity', 'sabotage', 'contraband', 'open_gate', 'new_fisheries', 'people_support'].include?(action_name)
        'Действия купцов'
      else
        'Политические действия'
      end
    when 'Player'
      'Игрок'
    when 'Settlement', 'Region'
      'Владения'
    when 'Army', 'Troop'
      'Армии'
    when 'Plant'
      'Производство'
    when 'Building'
      'Строительство'
    when 'Credit'
      'Финансы'
    when 'InfluenceItem'
      'Влияние'
    when 'PublicOrderItem'
      'Общественный порядок'
    when 'TechnologyItem'
      'Технологии'
    when 'Battle'
      'Сражения'
    when 'Job'
      'Должности'
    when 'GameParameter'
      'Игра'
    else
      'Прочее'
    end
  end

  def get_army_payment_stats(audits)
    troop_audits = audits.select { |a| a.auditable_type == 'Troop' && a.action == 'update' }
    
    # Группируем по отряду (по auditable_id) и находим последнее изменение для каждого
    troops_by_id = troop_audits.group_by(&:auditable_id)
    
    final_troop_states = troops_by_id.map do |troop_id, audits_for_troop|
      # Сортируем по времени создания и берем последнее изменение
      last_audit = audits_for_troop.max_by(&:created_at)
      
      changes = last_audit.audited_changes
      if changes&.dig('params') && changes['params'].is_a?(Array) && changes['params'].length == 2
        old_params, new_params = changes['params']
        old_paid = old_params&.dig('paid') || []
        new_paid = new_params&.dig('paid') || []
        
        # Определяем финальное состояние отряда
        is_paid = new_paid.any?
        troop_info = get_troop_info(last_audit)
        
        {
          troop_info: troop_info,
          is_paid: is_paid,
          audit: last_audit
        }
      else
        nil
      end
    end.compact
    
    paid_troops = final_troop_states.select { |state| state[:is_paid] }
    unpaid_troops = final_troop_states.reject { |state| state[:is_paid] }
    
    {
      paid_count: paid_troops.count,
      unpaid_count: unpaid_troops.count,
      paid_troops: paid_troops.map { |state| state[:troop_info] },
      unpaid_troops: unpaid_troops.map { |state| state[:troop_info] }
    }
  end

  def get_state_expenses_stats(audits)
    game_param_audits = audits.select { |a| a.auditable_type == 'GameParameter' }
    
    # Фильтруем аудиты с изменениями госрасходов
    expense_changes = game_param_audits.select do |audit|
      changes = audit.audited_changes
      if changes&.dig('params') && changes['params'].is_a?(Array) && changes['params'].length == 2
        old_params, new_params = changes['params']
        old_paid = old_params&.dig('state_expenses')
        new_paid = new_params&.dig('state_expenses')
        # Проверяем, что изменилось состояние оплаты
        old_paid != new_paid
      else
        false
      end
    end
    
    # Находим последнее изменение госрасходов за год
    last_expense_change = expense_changes.max_by(&:created_at)
    
    if last_expense_change
      changes = last_expense_change.audited_changes
      old_params, new_params = changes['params']
      old_paid = old_params&.dig('state_expenses')
      new_paid = new_params&.dig('state_expenses')
      
      {
        final_state: new_paid ? 'paid' : 'unpaid',
        paid: new_paid == true,
        unpaid: new_paid == false
      }
    else
      {
        final_state: 'unknown',
        paid: false,
        unpaid: false
      }
    end
  end

  def get_region_annexation_stats(audits)
    region_audits = audits.select { |a| a.auditable_type == 'Region' && a.action == 'update' }
    
    annexations = region_audits.select do |audit|
      changes = audit.audited_changes
      old_country = changes&.dig('country_id')&.first
      new_country = changes&.dig('country_id')&.last
      old_country != new_country && new_country.present?
    end
    
    # Детальная информация о присоединениях
    annexation_details = annexations.map do |audit|
      region = audit.auditable
      changes = audit.audited_changes
      old_country_id = changes&.dig('country_id')&.first
      new_country_id = changes&.dig('country_id')&.last
      
      old_country = Country.find_by(id: old_country_id)
      new_country = Country.find_by(id: new_country_id)
      
      {
        region_name: region&.name || "Неизвестный регион",
        from_country: old_country&.name || "Неизвестная страна",
        to_country: new_country&.name || "Неизвестная страна"
      }
    end
    
    # Разделяем на присоединения к Руси и к другим странам
    # Предполагаем, что Русь - это игрок с id=1 или название "Русь"
    russia_annexations = annexation_details.select do |annexation|
      to_country = annexation[:to_country]
      to_country == "Русь" || to_country.include?("Русь")
    end
    
    other_annexations = annexation_details.reject do |annexation|
      to_country = annexation[:to_country]
      to_country == "Русь" || to_country.include?("Русь")
    end
    
    # Группируем другие присоединения по стране
    other_by_country = other_annexations.group_by { |annexation| annexation[:to_country] }
    
    {
      total_annexations: annexations.count,
      to_russia: {
        count: russia_annexations.count,
        regions: russia_annexations.map { |a| a[:region_name] }
      },
      to_other_countries: {
        count: other_annexations.count,
        by_country: other_by_country.transform_values { |annexations| annexations.map { |a| a[:region_name] } }
      }
    }
  end

  def get_region_transfer_stats(audits)
    settlement_audits = audits.select { |a| a.auditable_type == 'Settlement' && a.action == 'update' }
    
    transfers = settlement_audits.select do |audit|
      changes = audit.audited_changes
      old_owner = changes&.dig('player_id')&.first
      new_owner = changes&.dig('player_id')&.last
      old_owner != new_owner && new_owner.present?
    end
    
    # Детальная информация о передачах
    transfer_details = transfers.map do |audit|
      settlement = audit.auditable
      changes = audit.audited_changes
      old_owner_id = changes&.dig('player_id')&.first
      new_owner_id = changes&.dig('player_id')&.last
      
      old_owner = Player.find_by(id: old_owner_id)
      new_owner = Player.find_by(id: new_owner_id)
      
      {
        settlement_name: settlement&.name || "Неизвестное поселение",
        from_player: old_owner&.name || "Неизвестный игрок",
        to_player: new_owner&.name || "Неизвестный игрок"
      }
    end
    
    # Группируем по игрокам
    by_player = transfer_details.group_by { |transfer| transfer[:to_player] }
    
    {
      total_transfers: transfers.count,
      by_player: by_player.transform_values { |transfers| transfers.map { |t| t[:settlement_name] } }
    }
  end

  def get_battle_stats(audits)
    battle_audits = audits.select { |a| a.auditable_type == 'Battle' }
    
    battles = battle_audits.map do |audit|
      battle = audit.auditable
      {
        attacker: battle&.attacker_name || "Неизвестный",
        defender: battle&.defender_name || "Неизвестный",
        winner: battle&.winner_name || "Неизвестный"
      }
    end
    
    {
      total_battles: battles.count,
      battles: battles
    }
  end

  def get_job_changes_stats(audits)
    job_audits = audits.select { |a| a.auditable_type == 'Job' && a.action == 'update' }
    
    changes = job_audits.map do |audit|
      {
        job_name: audit.auditable&.name || "Неизвестная должность",
        comment: audit.comment || "Должность изменена"
      }
    end
    
    {
      total_changes: changes.count,
      changes: changes
    }
  end

  def get_noble_actions_stats(audits)
    political_audits = audits.select { |a| a.auditable_type == 'PoliticalAction' }
    
    successful_actions = political_audits.select { |a| a.action == 'create' }
    failed_actions = political_audits.select { |a| a.action == 'destroy' }
    
    # Группируем по типу действия
    successful_by_type = successful_actions.group_by do |audit|
      audit.auditable&.political_action_type&.name || "Неизвестное действие"
    end
    
    {
      total_successful: successful_actions.count,
      total_failed: failed_actions.count,
      successful_by_type: successful_by_type.transform_values(&:count)
    }
  end

  def get_building_stats(audits)
    building_audits = audits.select { |a| a.auditable_type == 'Building' }
    
    created = building_audits.select { |a| a.action == 'create' }
    updated = building_audits.select { |a| a.action == 'update' }
    destroyed = building_audits.select { |a| a.action == 'destroy' }
    
    # Группируем по типу здания
    created_by_type = created.group_by do |audit|
      audit.auditable&.building_level&.building_type&.name || "Неизвестный тип"
    end
    
    {
      total_created: created.count,
      total_updated: updated.count,
      total_destroyed: destroyed.count,
      created_by_type: created_by_type.transform_values(&:count)
    }
  end

  def get_public_order_stats(audits)
    po_audits = audits.select { |a| a.auditable_type == 'PublicOrderItem' }
    
    changes = po_audits.map do |audit|
      {
        region_name: audit.auditable&.region&.name || "Неизвестный регион",
        value: audit.auditable&.value || 0
      }
    end
    
    # Группируем по региону
    by_region = changes.group_by { |c| c[:region_name] }
    
    {
      total_changes: changes.count,
      by_region: by_region.transform_values { |changes| changes.sum { |c| c[:value] } }
    }
  end

  def get_technology_stats(audits)
    tech_audits = audits.select { |a| a.auditable_type == 'TechnologyItem' }
    
    opened = tech_audits.select { |a| a.action == 'create' }
    closed = tech_audits.select { |a| a.action == 'destroy' }
    
    opened_techs = opened.map do |audit|
      audit.auditable&.technology&.name || "Неизвестная технология"
    end
    
    {
      total_opened: opened.count,
      total_closed: closed.count,
      opened_technologies: opened_techs
    }
  end

  def get_troop_info(audit)
    troop = audit.auditable
    if troop
      {
        troop_type: troop.troop_type&.name || "Неизвестный тип",
        army_name: troop.army&.name || "Неизвестная армия",
        owner_name: troop.army&.owner&.name || "Неизвестный владелец"
      }
    else
      # Для удаленных отрядов берем данные из audited_changes
      changes = audit.audited_changes
      troop_type_id = changes&.dig('troop_type_id')
      army_id = changes&.dig('army_id')
      
      troop_type = TroopType.find_by(id: troop_type_id)&.name || "Неизвестный тип"
      army = Army.find_by(id: army_id)
      army_name = army&.name || "Неизвестная армия"
      owner_name = army&.owner&.name || "Неизвестный владелец"
      
      {
        troop_type: troop_type,
        army_name: army_name,
        owner_name: owner_name
      }
    end
  end
end
