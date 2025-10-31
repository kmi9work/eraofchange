module VassalsAndRobbers
  class ChecklistValidator
    # Главный метод валидации условия
    def validate_condition(condition)
      case condition['type']
      when 'army_power'
        validate_army_power(condition['requirement'])
      when 'relations'
        validate_relations(condition['target_country_id'], condition['requirement'])
      when 'alliance'
        validate_alliance(condition['target_country_id'], condition['alliance_type'])
      when 'technology'
        validate_technology(condition['technology_ids'])
      when 'trade_turnover'
        validate_trade_turnover(condition['target_country_id'], condition['requirement'])
      when 'plant'
        validate_plant(condition['plant_type_name'], condition['level'])
      when 'public_order'
        validate_public_order(condition['region_id'] || condition['region_name'], condition['requirement'])
      when 'building'
        validate_building(condition['settlement_name'], condition['building_type'], condition['level'])
      else
        { success: false, current_value: 0, message: "Неизвестный тип условия: #{condition['type']}" }
      end
    end

    private

    # Проверка суммарной мощи армии Руси (всех игроков типа Знать)
    def validate_army_power(requirement)
      # Получаем всех игроков типа "Знать"
      noble_players = Player.joins(:player_type).where(player_types: { id: PlayerType::NOBLE })
      
      total_power = 0
      # Суммируем мощь всех армий всех игроков-знати
      noble_players.each do |noble|
        noble_armies = Army.where(owner_type: 'Player', owner_id: noble.id)
        noble_armies.each do |army|
          total_power += army.power
        end
      end
      
      is_met = total_power >= requirement.to_i
      
      {
        success: is_met,
        current_value: total_power,
        message: is_met ? "Мощь армии достаточна" : "Недостаточная мощь армии"
      }
    end

    # Проверка уровня отношений с страной
    def validate_relations(target_country_id, requirement)
      target_country = Country.find_by(id: target_country_id)
      return { success: false, current_value: 0, message: "Страна не найдена" } if target_country.nil?
      
      current_relations = target_country.relations
      is_met = current_relations >= requirement.to_i
      
      {
        success: is_met,
        current_value: current_relations,
        message: is_met ? "Отношения достаточны" : "Недостаточный уровень отношений"
      }
    end

    # Проверка наличия союза
    def validate_alliance(target_country_id, alliance_type_name)
      rus = Country.find_by(id: Country::RUS)
      target_country = Country.find_by(id: target_country_id)
      return { success: false, current_value: 0, message: "Страна не найдена" } if target_country.nil?
      
      alliance_type = AllianceType.find_by(name: alliance_type_name)
      return { success: false, current_value: 0, message: "Тип союза не найден" } if alliance_type.nil?
      
      alliance = Alliance.find_by(
        country_id: rus.id,
        partner_country_id: target_country_id,
        alliance_type_id: alliance_type.id
      )
      
      is_met = alliance.present?
      
      {
        success: is_met,
        current_value: is_met ? 1 : 0,
        message: is_met ? "Союз установлен" : "Союз не установлен"
      }
    end

    # Проверка открытых технологий
    def validate_technology(technology_ids)
      technology_ids = [technology_ids] unless technology_ids.is_a?(Array)
      
      missing_techs = []
      technology_ids.each do |tech_id|
        tech = Technology.find_by(id: tech_id)
        next if tech.nil?
        
        missing_techs << tech.name if tech.is_open != 1
      end
      
      is_met = missing_techs.empty?
      
      {
        success: is_met,
        current_value: is_met ? 1 : 0,
        message: is_met ? "Все технологии открыты" : "Не открыты: #{missing_techs.join(', ')}"
      }
    end

    # Проверка уровня товарооборота с страной
    def validate_trade_turnover(target_country_id, requirement)
      target_country = Country.find_by(id: target_country_id)
      return { success: false, current_value: 0, message: "Страна не найдена" } if target_country.nil?
      
      trade_level_data = target_country.show_current_trade_level
      current_level = trade_level_data[:current_level] || 0
      is_met = current_level >= requirement.to_i
      
      {
        success: is_met,
        current_value: current_level,
        message: is_met ? "Товарооборот достаточен" : "Недостаточный товарооборот"
      }
    end

    # Проверка наличия предприятия определенного уровня
    def validate_plant(plant_type_name, required_level)
      plant_type = PlantType.find_by(name: plant_type_name)
      return { success: false, current_value: 0, message: "Тип предприятия не найден" } if plant_type.nil?
      
      # Проверяем наличие предприятия нужного уровня
      plant_level = PlantLevel.find_by(plant_type_id: plant_type.id, level: required_level.to_i)
      return { success: false, current_value: 0, message: "Уровень предприятия не найден" } if plant_level.nil?
      
      plants_at_level = Plant.where(plant_level_id: plant_level.id)
      is_met = plants_at_level.count > 0
      current_count = plants_at_level.count
      
      {
        success: is_met,
        current_value: current_count,
        message: is_met ? "Предприятие построено" : "Предприятие не построено"
      }
    end

    # Проверка общественного порядка в регионе
    def validate_public_order(region_identifier, requirement)
      # region_identifier может быть как ID, так и название
      region = if region_identifier.is_a?(Integer) || region_identifier.to_s.match?(/^\d+$/)
        Region.find_by(id: region_identifier)
      else
        Region.find_by(name: region_identifier)
      end
      
      return { success: false, current_value: 0, message: "Регион не найден" } if region.nil?
      
      current_po = region.show_overall_po
      is_met = current_po >= requirement.to_i
      
      {
        success: is_met,
        current_value: current_po,
        message: is_met ? "Общественный порядок достаточен" : "Недостаточный общественный порядок"
      }
    end

    # Проверка наличия постройки в населенном пункте
    def validate_building(settlement_name, building_type_name, required_level)
      settlement = Settlement.find_by(name: settlement_name)
      return { success: false, current_value: 0, message: "Населенный пункт не найден" } if settlement.nil?
      
      building_type = BuildingType.find_by(name: building_type_name)
      return { success: false, current_value: 0, message: "Тип постройки не найден" } if building_type.nil?
      
      building_level = BuildingLevel.find_by(building_type_id: building_type.id, level: required_level.to_i)
      return { success: false, current_value: 0, message: "Уровень постройки не найден" } if building_level.nil?
      
      building = Building.find_by(settlement_id: settlement.id, building_level_id: building_level.id)
      is_met = building.present?
      
      {
        success: is_met,
        current_value: is_met ? 1 : 0,
        message: is_met ? "Постройка создана" : "Постройка не создана"
      }
    end
  end
end

