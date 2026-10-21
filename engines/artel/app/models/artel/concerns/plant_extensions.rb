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
          return
        end

        # Гильдия-владелец должна относиться к текущему государству (Д14.2):
        # при игре за одну страну это гильдии «Руси», как и было
        current_country = Country.current
        return if current_country.nil?

        guild = economic_subject
        return if guild.nil? || guild.country_id.nil? || guild.country_id == current_country.id

        errors.add(:economic_subject, "Предприятие может принадлежать только гильдии текущего государства")
      end
    end
  end
end
