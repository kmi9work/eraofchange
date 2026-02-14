# В плагине Artel предприятия не привязаны к регионам и принадлежат только гильдии.
# API доступных мест возвращает для каждого типа предприятия один вариант "Гильдия" без региона.
module Artel
  module Concerns
    module PlantPlacesControllerExtensions
      extend ActiveSupport::Concern

      included do
        prepend InstanceMethods
      end

      module InstanceMethods
        def available_places
          craftsmen_technology = Technology.find_by(id: Technology::CRAFTSMEN)
          craftsmen_open = craftsmen_technology&.is_open == 1
          craftsmen_tech_name = craftsmen_technology&.name || "Ремесловые люди"
          craftsmen_required_names = ["Кузница", "Ювелирная мастерская"]

          result = PlantType.all.map do |plant_type|
            technology_requirements = []
            if craftsmen_required_names.include?(plant_type.name)
              technology_requirements << {
                id: Technology::CRAFTSMEN,
                name: craftsmen_tech_name,
                open: craftsmen_open
              }
            end

            # Одно "место" — гильдия без привязки к региону (id: nil — предприятие без plant_place_id)
            available_places = [
              {
                id: nil,
                name: "Гильдия (без привязки к региону)",
                region_id: nil,
                region_name: nil,
                region_country_id: nil,
                allowed: true
              }
            ]

            {
              plant_type_id: plant_type.id,
              plant_type_name: plant_type.name,
              plant_category: plant_type.plant_category&.name,
              plant_category_id: plant_type.plant_category_id,
              technology_requirements: technology_requirements,
              available_places: available_places
            }
          end

          render json: result
        end
      end
    end
  end
end
