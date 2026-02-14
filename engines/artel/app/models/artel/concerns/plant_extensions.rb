# В плагине Artel предприятия принадлежат только гильдии и не привязаны к региону (plant_place не обязателен).
module Artel
  module Concerns
    module PlantExtensions
      extend ActiveSupport::Concern

      included do
        validate :artel_plant_belongs_to_guild, if: -> { ENV['ACTIVE_GAME'] == 'artel' }
      end

      private

      def artel_plant_belongs_to_guild
        return if economic_subject_type.blank? && economic_subject_id.blank?

        if economic_subject_type != 'Guild'
          errors.add(:economic_subject, "В игре Артель предприятия могут принадлежать только гильдии")
        end
      end
    end
  end
end
