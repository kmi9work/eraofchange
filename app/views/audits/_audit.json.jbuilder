json.extract! audit, :id, :auditable, :auditable_type, :action, :created_at

# Добавляем год для всех аудитов
def get_audit_year(audit)
  # Используем только год из самого аудита
  audit.year if audit.respond_to?(:year) && audit.year
end

json.year get_audit_year(audit)

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
if audit.auditable_type == 'InfluenceItem'
  if audit.auditable
    # Для существующих элементов влияния
    json.player_name audit.auditable.player&.name
    json.value audit.auditable.value
    json.comment audit.auditable.comment
  else
    # Для удаленных элементов влияния получаем данные из audited_changes
    player_id = audit.audited_changes&.dig('player_id')
    if player_id
      player = Player.find_by(id: player_id)
      json.player_name player&.name
    end
    json.value audit.audited_changes&.dig('value')
    json.comment audit.audited_changes&.dig('comment')
  end
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
  json.year audit.year
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
    json.relation_year audit.year
  else
    # Для удаленных RelationItem получаем данные из audited_changes
    country_id = audit.audited_changes&.dig('country_id')
    country = Country.find_by(id: country_id)
    json.country_name country&.name
    json.relation_value audit.audited_changes&.dig('value')
    json.relation_comment audit.audited_changes&.dig('comment')
    json.relation_year audit.year
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

# Добавляем дополнительные поля для предприятий (Plant)
if audit.auditable_type == 'Plant'
  # Добавляем ID предприятия для отслеживания
  if audit.auditable
    json.auditable_plant_id audit.auditable.id
  elsif audit.audited_changes['id']
    # Для удаленных предприятий берем ID из audited_changes
    plant_id = audit.audited_changes['id']
    plant_id = plant_id.is_a?(Array) ? plant_id.first : plant_id
    json.auditable_plant_id plant_id
  end
  json.auditable_id audit.auditable_id if audit.respond_to?(:auditable_id)
  
  # Для create и destroy нужно брать данные из audited_changes, чтобы получить уровень на момент создания/удаления
  # Для update можно использовать текущий объект, но лучше тоже из audited_changes для консистентности
  if audit.action == 'create' || audit.action == 'destroy' || !audit.auditable
    # Для созданных или удаленных предприятий берем данные из audited_changes
    if audit.audited_changes['economic_subject_id']
      economic_subject_id = audit.audited_changes['economic_subject_id']
      economic_subject_id = economic_subject_id.is_a?(Array) ? economic_subject_id.last : economic_subject_id
      economic_subject_type = audit.audited_changes['economic_subject_type']
      economic_subject_type = economic_subject_type.is_a?(Array) ? economic_subject_type.last : economic_subject_type
      json.economic_subject_type economic_subject_type
      
      if economic_subject_type == 'Guild' && economic_subject_id
        guild = Guild.find_by(id: economic_subject_id)
        json.guild_name guild&.name
      end
    end
    
    if audit.audited_changes['plant_level_id']
      plant_level_id = audit.audited_changes['plant_level_id']
      # Для create берем последнее значение (новый уровень), для destroy - первое (старый уровень)
      if plant_level_id.is_a?(Array)
        plant_level_id = audit.action == 'create' ? plant_level_id.last : plant_level_id.first
      end
      plant_level = PlantLevel.find_by(id: plant_level_id)
      json.plant_type_name plant_level&.plant_type&.name
      json.plant_level_level plant_level&.level
      json.cost plant_level&.price
      # Добавляем максимальную производительность
      if plant_level&.formulas
        max_products = []
        plant_level.formulas.each do |formula|
          if formula['max_product']
            max_products.concat(formula['max_product'])
          end
        end
        json.max_products max_products
      end
    end
  elsif audit.auditable
    # Для существующих предприятий при update используем текущий объект как fallback
    plant = audit.auditable
    json.economic_subject_type plant.economic_subject_type
    json.guild_name plant.economic_subject&.name if plant.economic_subject_type == 'Guild'
    json.plant_type_name plant.plant_level&.plant_type&.name
    json.plant_level_level plant.plant_level&.level
    json.cost plant.plant_level&.price
    # Добавляем максимальную производительность
    if plant.plant_level&.formulas
      max_products = []
      plant.plant_level.formulas.each do |formula|
        if formula['max_product']
          max_products.concat(formula['max_product'])
        end
      end
      json.max_products max_products
    end
  end
  
  # Обработка изменений уровня при upgrade
  if audit.action == 'update' && audit.audited_changes['plant_level_id']
    plant_level_changes = audit.audited_changes['plant_level_id']
    if plant_level_changes.is_a?(Array)
      old_level_id = plant_level_changes[0]
      new_level_id = plant_level_changes[1]
      old_level = PlantLevel.find_by(id: old_level_id)
      new_level = PlantLevel.find_by(id: new_level_id)
      json.old_plant_level_level old_level&.level
      json.new_plant_level_level new_level&.level
      json.old_cost old_level&.price
      json.new_cost new_level&.price
      # Добавляем максимальную производительность для старого и нового уровня
      if old_level&.formulas
        old_max_products = []
        old_level.formulas.each do |formula|
          if formula['max_product']
            old_max_products.concat(formula['max_product'])
          end
        end
        json.old_max_products old_max_products
      end
      if new_level&.formulas
        new_max_products = []
        new_level.formulas.each do |formula|
          if formula['max_product']
            new_max_products.concat(formula['max_product'])
          end
        end
        json.new_max_products new_max_products
      end
    end
  end
end
