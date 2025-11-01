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
          
          result = PlantType.all.map do |plant_type|
            # Для перерабатывающих предприятий - все PlantPlace с категорией "Перерабатывающее"
            # Для добывающих - только PlantPlace, которые связаны с нужным fossil_type
            # Фильтруем регионы, принадлежащие Руси или вассальным странам
            if plant_type.plant_category_id == PlantCategory::PROCESSING
              available_places = PlantPlace.includes(:region)
                                            .where(plant_category_id: PlantCategory::PROCESSING)
                                            .joins(:region)
                                            .where(regions: { country_id: allowed_country_ids })
            else
              # Добывающее предприятие
              if plant_type.fossil_type_id.present?
                # Находим PlantPlace, которые содержат нужный fossil_type и в регионах Руси или вассальных стран
                available_places = PlantPlace.includes(:region, :fossil_types)
                                              .where(plant_category_id: PlantCategory::EXTRACTIVE)
                                              .joins(:region, :fossil_types)
                                              .where(regions: { country_id: allowed_country_ids })
                                              .where(fossil_types: { id: plant_type.fossil_type_id })
              else
                available_places = []
              end
            end

            {
              plant_type_id: plant_type.id,
              plant_type_name: plant_type.name,
              plant_category: plant_type.plant_category&.name,
              plant_category_id: plant_type.plant_category_id,
              available_places: available_places.map do |place|
                {
                  id: place.id,
                  name: place.name,
                  region_id: place.region_id,
                  region_name: place.region&.name
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
