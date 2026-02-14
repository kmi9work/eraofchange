# В плагине Artel предприятия принадлежат только гильдии, plant_place не обязателен.
module Artel
  module Concerns
    module PlantsControllerExtensions
      extend ActiveSupport::Concern

      included do
        prepend InstanceMethods
      end

      module InstanceMethods
        private

        def write_economic_subject
          economic_subject_value = params[:plant]&.dig(:economic_subject) || params[:economic_subject]
          return unless economic_subject_value.present?

          es_id, es_type = economic_subject_value.split('_')
          # В Artel только гильдия может быть владельцем предприятия
          if es_type == 'Guild'
            @plant.economic_subject = Guild.find(es_id.to_i)
          else
            # Игроки не могут владеть предприятиями — сбрасываем или не устанавливаем
            @plant.economic_subject = nil
          end
        end
      end
    end
  end
end
