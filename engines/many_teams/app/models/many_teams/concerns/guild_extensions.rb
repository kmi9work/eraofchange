# Гильдия в режиме many_teams: эмбарго и разрешения на строительство и работу.
module ManyTeams
  module Concerns
    module GuildExtensions
      def many_teams_embargoed_by?(country)
        return false unless ManyTeams.active?

        ManyTeams::GuildEmbargo.embargoed?(country, self)
      end

      def many_teams_embargoes
        ManyTeams::GuildEmbargo.for_guild(self)
      end

      def many_teams_build_allowed_in?(country)
        return false unless ManyTeams.active?

        ManyTeams::GuildCountryPermission.allowed?(self, country)
      end

      # Страны, в которых гильдии разрешены строительство и работа (с умолчанием).
      def many_teams_build_countries
        return [] unless ManyTeams.active?

        ::Country.order(:id).select { |country| ManyTeams::GuildCountryPermission.allowed?(self, country) }
      end
    end
  end
end
