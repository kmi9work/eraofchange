json.extract! audit, :id, :auditable, :auditable_type, :action, :created_at

# Добавляем информацию о пользователе с должностью
if audit.user
  json.user do
    json.name audit.user.name
    json.job audit.user.job
  end
else
  json.user nil
end

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
  json.year audit.auditable.year
  json.success audit.auditable.success
end

# Добавляем дополнительные поля для элементов влияния
if audit.auditable_type == 'InfluenceItem' && audit.auditable
  json.player_name audit.auditable.player&.name
  json.value audit.auditable.value
  json.comment audit.auditable.comment
  json.year audit.auditable.year
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
  json.year GameParameter.current_year
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
  json.year GameParameter.current_year
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
  json.year audit.audited_changes['year'] || audit.auditable&.year || GameParameter.current_year
end
