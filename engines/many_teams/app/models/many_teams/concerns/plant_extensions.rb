# Проверки строительства предприятия гильдией (п. 4 и п. 7).
#
#  * строить можно на территории государств игроков (подтверждённых на «Дашборде»);
#  * добывающее предприятие требует разрешения «государство × гильдия».
#
# Правило проверяется в модели, поэтому действует для всех клиентов (фронт,
# мобильное приложение, консоль) — обойти его через другой эндпоинт нельзя.
module ManyTeams
  module Concerns
    module PlantExtensions
      def self.prepended(base)
        base.validate :many_teams_build_allowed
      end

      def many_teams_extractive?
        !!plant_level&.plant_type&.plant_category&.is_extractive
      end

      def many_teams_build_country
        plant_place&.region&.country
      end

      # Ярлык для API: запрещена ли добыча этого предприятия там, где оно стоит.
      def many_teams_extraction_forbidden?
        return false unless ManyTeams.active?
        return false unless many_teams_extractive?

        guild = economic_subject
        return false unless guild.is_a?(::Guild)

        country = many_teams_build_country
        return false if country.nil?

        !ManyTeams::GuildExtractionPermission.allowed?(guild, country)
      end

      private

      def many_teams_build_allowed
        return unless ManyTeams.active?

        country = many_teams_build_country
        return if country.nil? # без региона проверять нечего — как и раньше

        guild = economic_subject
        if guild.is_a?(::Guild)
          unless ManyTeams::PlayerCountry.buildable?(country)
            errors.add(:plant_place, "строительство разрешено только на территории государств игроков " \
                                    "(государство «#{country.name}» не подтверждено на Дашборде)")
            return
          end

          if many_teams_extractive? && !ManyTeams::GuildExtractionPermission.allowed?(guild, country)
            errors.add(:plant_place, "добыча в государстве «#{country.name}» запрещена для гильдии «#{guild.name}»")
          end
        end
      end
    end
  end
end
