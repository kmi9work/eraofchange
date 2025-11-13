module VassalsAndRobbers
  module Concerns
    module PlantPlacesControllerExtensions
      extend ActiveSupport::Concern

      included do
        # Переопределяем метод available_places через prepend
        prepend InstanceMethods
      end

      module InstanceMethods
        def available_places
          # Получаем список ID вассальных стран
          vassal_country_ids = VassalsAndRobbers::Checklist.vassal_country_ids
          # Добавляем Русь к списку доступных стран для строительства
          allowed_country_ids = [Country::RUS] + vassal_country_ids
          
          craftsmen_technology = Technology.find_by(id: Technology::CRAFTSMEN)
          craftsmen_open = craftsmen_technology&.is_open == 1
          craftsmen_tech_name = craftsmen_technology&.name || "Ремесловые люди"
          craftsmen_required_names = ["Кузница", "Ювелирная мастерская"]

          result = PlantType.all.map do |plant_type|
            # Для перерабатывающих предприятий - все PlantPlace с категорией "Перерабатывающее"
            # Для добывающих - только PlantPlace, которые связаны с нужным fossil_type
            if plant_type.plant_category_id == PlantCategory::PROCESSING
              available_places = PlantPlace.includes(:region)
                                            .where(plant_category_id: PlantCategory::PROCESSING)
            else
              # Добывающее предприятие
              if plant_type.fossil_type_id.present?
                # Находим PlantPlace, которые содержат нужный fossil_type
                available_places = PlantPlace.includes(:region, :fossil_types)
                                              .where(plant_category_id: PlantCategory::EXTRACTIVE)
                                              .joins(:fossil_types)
                                              .where(fossil_types: { id: plant_type.fossil_type_id })
              else
                available_places = []
              end
            end

            technology_requirements = []
            if craftsmen_required_names.include?(plant_type.name)
              technology_requirements << {
                id: Technology::CRAFTSMEN,
                name: craftsmen_tech_name,
                open: craftsmen_open
              }
            end

            {
              plant_type_id: plant_type.id,
              plant_type_name: plant_type.name,
              plant_category: plant_type.plant_category&.name,
              plant_category_id: plant_type.plant_category_id,
              technology_requirements: technology_requirements,
              available_places: available_places.map do |place|
                region = place.region
                allowed = allowed_country_ids.include?(region&.country_id)

                {
                  id: place.id,
                  name: place.name,
                  region_id: place.region_id,
                  region_name: region&.name,
                  region_country_id: region&.country_id,
                  allowed: allowed
                }
              end
            }
          end

          render json: result
        end
      end
    end
  end
end
