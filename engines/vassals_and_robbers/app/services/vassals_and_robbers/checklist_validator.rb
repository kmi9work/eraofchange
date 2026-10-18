module VassalsAndRobbers
  # Проверка условий чек-листа вассалитета.
  #
  # Все проверки считаются относительно сюзерена чек-листа: его знать, его армии,
  # его регионы и владения, его отношения и технологии (Д14.1 п. 3). При игре за одну
  # страну (сюзерен — «Русь») поведение совпадает с прежним.
  class ChecklistValidator
    def initialize(sovereign = Country.current)
      @sovereign = sovereign || Country.current
    end

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

    attr_reader :sovereign

    # Проверка суммарной мощи армии сюзерена (армии его знати и самого государства)
    def validate_army_power(requirement)
      total_power = 0

      if sovereign
        noble_ids = Player.nobles.where(country_id: sovereign.id).select(:id)
        Army.where(owner_type: 'Player', owner_id: noble_ids).each do |army|
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

    # Проверка уровня отношений страны с сюзереном чек-листа
    def validate_relations(target_country_id, requirement)
      target_country = Country.find_by(id: target_country_id)
      return { success: false, current_value: 0, message: "Страна не найдена" } if target_country.nil?

      current_relations =
        if sovereign.nil? || target_country.id == sovereign.id
          target_country.relations
        else
          target_country.relations(sovereign)
        end
      is_met = current_relations >= requirement.to_i

      {
        success: is_met,
        current_value: current_relations,
        message: is_met ? "Отношения достаточны" : "Недостаточный уровень отношений"
      }
    end

    # Проверка наличия союза страны с сюзереном чек-листа
    def validate_alliance(target_country_id, alliance_type_name)
      target_country = Country.find_by(id: target_country_id)
      return { success: false, current_value: 0, message: "Страна не найдена" } if target_country.nil?
      return { success: false, current_value: 0, message: "Сюзерен не определен" } if sovereign.nil?

      alliance_type = AllianceType.find_by(name: alliance_type_name)
      return { success: false, current_value: 0, message: "Тип союза не найден" } if alliance_type.nil?

      # Союз мог быть заведён с любой стороны пары — проверяем оба направления
      alliance = Alliance.find_by(
        country_id: sovereign.id,
        partner_country_id: target_country_id,
        alliance_type_id: alliance_type.id
      ) || Alliance.find_by(
        country_id: target_country_id,
        partner_country_id: sovereign.id,
        alliance_type_id: alliance_type.id
      )

      is_met = alliance.present?

      {
        success: is_met,
        current_value: is_met ? 1 : 0,
        message: is_met ? "Союз установлен" : "Союз не установлен"
      }
    end

    # Проверка открытых технологий у сюзерена чек-листа
    def validate_technology(technology_ids)
      technology_ids = [technology_ids] unless technology_ids.is_a?(Array)

      missing_techs = []
      technology_ids.each do |tech_id|
        tech = Technology.find_by(id: tech_id)
        next if tech.nil?

        missing_techs << tech.name unless tech.is_open(sovereign) == 1
      end

      is_met = missing_techs.empty?

      {
        success: is_met,
        current_value: is_met ? 1 : 0,
        message: is_met ? "Все технологии открыты" : "Не открыты: #{missing_techs.join(', ')}"
      }
    end

    # Проверка уровня товарооборота страны с сюзереном чек-листа
    def validate_trade_turnover(target_country_id, requirement)
      target_country = Country.find_by(id: target_country_id)
      return { success: false, current_value: 0, message: "Страна не найдена" } if target_country.nil?

      trade_level_data = target_country.show_current_trade_level(sovereign)
      current_level = trade_level_data[:current_level] || 0
      is_met = current_level >= requirement.to_i

      {
        success: is_met,
        current_value: current_level,
        message: is_met ? "Товарооборот достаточен" : "Недостаточный товарооборот"
      }
    end

    # Проверка наличия предприятия определенного уровня во владениях сюзерена
    def validate_plant(plant_type_name, required_level)
      plant_type = PlantType.find_by(name: plant_type_name)
      return { success: false, current_value: 0, message: "Тип предприятия не найден" } if plant_type.nil?

      # Проверяем наличие предприятия нужного уровня
      plant_level = PlantLevel.find_by(plant_type_id: plant_type.id, level: required_level.to_i)
      return { success: false, current_value: 0, message: "Уровень предприятия не найден" } if plant_level.nil?

      plants_at_level = Plant.where(plant_level_id: plant_level.id).select do |plant|
        plant_country_id(plant) == sovereign&.id
      end
      is_met = plants_at_level.any?

      {
        success: is_met,
        current_value: plants_at_level.count,
        message: is_met ? "Предприятие построено" : "Предприятие не построено"
      }
    end

    # Государство предприятия: у гильдии — её государство, у купца — государство купца
    def plant_country_id(plant)
      subject = plant.economic_subject
      return subject.country_id if subject.respond_to?(:country_id)

      nil
    end

    # Проверка общественного порядка в регионе сюзерена
    def validate_public_order(region_identifier, requirement)
      # region_identifier может быть как ID, так и название
      region = if region_identifier.is_a?(Integer) || region_identifier.to_s.match?(/^\d+$/)
        Region.find_by(id: region_identifier)
      else
        Region.find_by(name: region_identifier)
      end

      return { success: false, current_value: 0, message: "Регион не найден" } if region.nil?

      # Регион другого государства не считается владением сюзерена
      if sovereign && region.country_id != sovereign.id
        return { success: false, current_value: 0, message: "Регион не принадлежит государству сюзерена" }
      end

      current_po = region.show_overall_po(sovereign)
      is_met = current_po >= requirement.to_i

      {
        success: is_met,
        current_value: current_po,
        message: is_met ? "Общественный порядок достаточен" : "Недостаточный общественный порядок"
      }
    end

    # Проверка наличия постройки в населенном пункте сюзерена
    def validate_building(settlement_name, building_type_name, required_level)
      settlement = Settlement.for_country(sovereign).find_by(name: settlement_name)
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
