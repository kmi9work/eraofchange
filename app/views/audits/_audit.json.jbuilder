json.extract! audit, :id, :auditable, :auditable_type, :action, :created_at

# Добавляем год для всех аудитов
json.year audit.auditable&.respond_to?(:year) ? audit.auditable.year : GameParameter.current_year

# Добавляем информацию о пользователе системы (кто совершил действие)
if audit.user
  json.user do
    json.name audit.user.name
    json.job audit.user.job
  end
else
  json.user nil
end

# Добавляем информацию об игроке (кто владеет объектом)
player = nil
if audit.auditable&.respond_to?(:owner) && audit.auditable.owner
  # Для объектов с owner (например, Army)
  player = audit.auditable.owner
elsif audit.auditable&.respond_to?(:player) && audit.auditable.player
  # Для объектов с player (например, Settlement, Region)
  player = audit.auditable.player
end

if player
  json.player do
    json.name player.name
    if player.respond_to?(:jobs)
      json.jobs player.jobs.pluck(:name).join(', ')
    else
      json.jobs nil
    end
  end
else
  json.player nil
end

# Добавляем информацию о том, просмотрено ли событие
json.is_viewed @viewed_audit_ids.include?(audit.id)

# Обрабатываем audited_changes для зданий
if audit.auditable_type == 'Building' && audit.audited_changes['building_level_id']
  audited_changes = audit.audited_changes.dup
  if audited_changes['building_level_id'].is_a?(Array)
    # Для update: [старый_id, новый_id]
    old_level = BuildingLevel.find_by(id: audited_changes['building_level_id'][0])&.level
    new_level = BuildingLevel.find_by(id: audited_changes['building_level_id'][1])&.level
    audited_changes['building_level'] = [old_level, new_level]
  else
    # Для create или destroy: один ID
    level = BuildingLevel.find_by(id: audited_changes['building_level_id'])&.level
    if audit.action == 'create'
      audited_changes['building_level'] = [nil, level]
    elsif audit.action == 'destroy'
      audited_changes['building_level'] = [level, nil]
    else
      audited_changes['building_level'] = [nil, level]
    end
  end
  json.audited_changes audited_changes
else
  json.audited_changes audit.audited_changes
end

# Добавляем дополнительные поля для политических действий
if audit.auditable_type == 'PoliticalAction' && audit.auditable
  json.job_name audit.auditable.job&.name
  json.action_name audit.auditable.political_action_type&.name
  json.success audit.auditable.success
end

# Добавляем дополнительные поля для элементов влияния
if audit.auditable_type == 'InfluenceItem' && audit.auditable
  json.player_name audit.auditable.player&.name
  json.value audit.auditable.value
  json.comment audit.auditable.comment
end

# Добавляем дополнительные поля для зданий
if audit.auditable_type == 'Building'
  if audit.auditable
    # Для существующих зданий
    json.settlement_name audit.auditable.settlement&.name
    json.building_type_name audit.auditable.building_level&.building_type&.name
    json.building_level_name audit.auditable.building_level&.name
    json.building_level_level audit.auditable.building_level&.level
  else
    # Для удаленных зданий берем данные из audited_changes
    if audit.audited_changes['settlement_id']
      settlement_id = audit.audited_changes['settlement_id']
      settlement_id = settlement_id.is_a?(Array) ? settlement_id[0] : settlement_id
      settlement = Settlement.find_by(id: settlement_id)
      json.settlement_name settlement&.name
    end
    
    if audit.audited_changes['building_level_id']
      building_level_id = audit.audited_changes['building_level_id']
      building_level_id = building_level_id.is_a?(Array) ? building_level_id[0] : building_level_id
      building_level = BuildingLevel.find_by(id: building_level_id)
      json.building_type_name building_level&.building_type&.name
      json.building_level_name building_level&.name
      json.building_level_level building_level&.level
    end
  end
end

# Добавляем дополнительные поля для поселений
if audit.auditable_type == 'Settlement'
  if audit.audited_changes['player_id']
    player_id = audit.audited_changes['player_id']
    if player_id.is_a?(Array)
      old_player_id = player_id[0]
      new_player_id = player_id[1]
      old_player = Player.find_by(id: old_player_id)
      new_player = Player.find_by(id: new_player_id)
      json.old_player_name old_player&.name
      json.new_player_name new_player&.name
    else
      player = Player.find_by(id: player_id)
      json.player_name player&.name
    end
  end
  
  # Добавляем год для поселений
end

# Добавляем дополнительные поля для регионов
if audit.auditable_type == 'Region'
  if audit.audited_changes['country_id']
    country_id = audit.audited_changes['country_id']
    if country_id.is_a?(Array)
      old_country_id = country_id[0]
      new_country_id = country_id[1]
      old_country = Country.find_by(id: old_country_id)
      new_country = Country.find_by(id: new_country_id)
      json.old_country_name old_country&.name
      json.new_country_name new_country&.name
    else
      country = Country.find_by(id: country_id)
      json.country_name country&.name
    end
  end
  
  # Добавляем год для регионов
end

# Добавляем дополнительные поля для общественного порядка
if audit.auditable_type == 'PublicOrderItem'
  # Добавляем название региона
  if audit.audited_changes['region_id']
    region_id = audit.audited_changes['region_id']
    region = Region.find_by(id: region_id)
    json.region_name region&.name
  elsif audit.auditable&.region_id
    region = Region.find_by(id: audit.auditable.region_id)
    json.region_name region&.name
  end
  
  # Добавляем год
end

# Добавляем дополнительные поля для технологий
if audit.auditable_type == 'TechnologyItem'
  # Добавляем название технологии
  if audit.auditable&.technology
    json.technology_name audit.auditable.technology.name
  end
  
  # Добавляем год
end

# Добавляем дополнительные поля для сражений
if audit.auditable_type == 'Battle'
  # Добавляем данные о сражении
  json.attacker_name audit.auditable&.attacker_name
  json.defender_name audit.auditable&.defender_name
  json.winner_name audit.auditable&.winner_name
  json.loser_name audit.auditable&.loser_name
  json.attacker_owner_name audit.auditable&.attacker_owner_name
  json.defender_owner_name audit.auditable&.defender_owner_name
  json.winner_owner_name audit.auditable&.winner_owner_name
  json.attacker_army_name audit.auditable&.attacker_army_name
  json.defender_army_name audit.auditable&.defender_army_name
  json.winner_army_name audit.auditable&.winner_army_name
  json.damage audit.auditable&.damage
  json.year audit.auditable&.year || GameParameter.current_year
end

# Добавляем дополнительные поля для армий
if audit.auditable_type == 'Army'
  if audit.auditable
    # Для существующих армий
    json.army_name audit.auditable.name
    json.army_owner_name audit.auditable.owner&.name
    json.settlement_name audit.auditable.settlement&.name
  else
    # Для удаленных армий получаем данные по ID из audited_changes
    army_id = audit.audited_changes&.dig('id') || audit.audited_changes&.dig('army_id')
    owner_id = audit.audited_changes&.dig('owner_id')
    settlement_id = audit.audited_changes&.dig('settlement_id')
    
    army = Army.find_by(id: army_id)
    owner = nil
    settlement = nil
    
    if owner_id
      owner_type = audit.audited_changes&.dig('owner_type')
      if owner_type == 'Player'
        owner = Player.find_by(id: owner_id)
      elsif owner_type == 'Country'
        owner = Country.find_by(id: owner_id)
      end
    end
    
    settlement = Settlement.find_by(id: settlement_id) if settlement_id
    
    json.army_name army&.name || audit.audited_changes&.dig('name')
    json.army_owner_name owner&.name
    json.settlement_name settlement&.name
  end
end

# Добавляем дополнительные поля для отрядов
if audit.auditable_type == 'Troop'
  if audit.auditable
    # Для существующих отрядов
    json.troop_type_name audit.auditable.troop_type&.name
    json.army_name audit.auditable.army&.name
    json.army_owner_name audit.auditable.army&.owner&.name
  else
    # Для удаленных отрядов получаем данные по ID из audited_changes
    troop_type_id = audit.audited_changes&.dig('troop_type_id')
    army_id = audit.audited_changes&.dig('army_id')
    
    troop_type = TroopType.find_by(id: troop_type_id)
    army = Army.find_by(id: army_id)
    
    json.troop_type_name troop_type&.name
    json.army_name army&.name
    json.army_owner_name army&.owner&.name
  end
end

# Добавляем дополнительные поля для GameParameter
if audit.auditable_type == 'GameParameter'
  json.comment audit.comment
end

# Добавляем дополнительные поля для Job
if audit.auditable_type == 'Job'
  json.comment audit.comment
end

# Добавляем дополнительные поля для RelationItem
if audit.auditable_type == 'RelationItem'
  if audit.auditable
    json.country_name audit.auditable.country&.name
    json.relation_value audit.auditable.value
    json.relation_comment audit.auditable.comment
    json.relation_year audit.auditable.year
  else
    # Для удаленных RelationItem получаем данные из audited_changes
    country_id = audit.audited_changes&.dig('country_id')
    country = Country.find_by(id: country_id)
    json.country_name country&.name
    json.relation_value audit.audited_changes&.dig('value')
    json.relation_comment audit.audited_changes&.dig('comment')
    json.relation_year audit.audited_changes&.dig('year')
  end
end

# Добавляем дополнительные поля для Country
if audit.auditable_type == 'Country'
  if audit.auditable
    json.country_name audit.auditable.name
    # Проверяем изменения в params (эмбарго)
    if audit.audited_changes&.dig('params')
      old_params = audit.audited_changes['params'][0]
      new_params = audit.audited_changes['params'][1]
      old_embargo = old_params&.dig('embargo')
      new_embargo = new_params&.dig('embargo')
      
      if old_embargo != new_embargo
        json.embargo_changed true
        json.old_embargo old_embargo
        json.new_embargo new_embargo
      end
    end
  else
    # Для удаленных стран
    json.country_name audit.audited_changes&.dig('name')
  end
end
