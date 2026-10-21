# Государство в режиме many_teams: эмбарго на гильдии и разрешения на добычу.
module ManyTeams
  module Concerns
    module CountryExtensions
      # Эмбарго, наложенные ЭТИМ государством.
      def many_teams_guild_embargoes
        ManyTeams::GuildEmbargo.by_imposer(self)
      end

      # Гильдии, на которые наложены эмбарго этим государством.
      def many_teams_embargoed_guilds
        ::Guild.where(id: many_teams_guild_embargoes.select(:guild_id))
      end

      def many_teams_extraction_permissions
        ManyTeams::GuildExtractionPermission.where(country_id: id)
      end

      def many_teams_player_country?
        ManyTeams::PlayerCountry.confirmed?(self)
      end
    end
  end
end
