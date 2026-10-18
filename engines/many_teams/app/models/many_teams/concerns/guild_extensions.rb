# Гильдия в режиме many_teams: эмбарго и разрешения на добычу.
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

      def many_teams_extraction_allowed_in?(country)
        return false unless ManyTeams.active?

        ManyTeams::GuildExtractionPermission.allowed?(self, country)
      end

      # Страны, в которых гильдии разрешена добыча (с учётом умолчания).
      def many_teams_extraction_countries
        return [] unless ManyTeams.active?

        ::Country.order(:id).select { |country| ManyTeams::GuildExtractionPermission.allowed?(self, country) }
      end
    end
  end
end
