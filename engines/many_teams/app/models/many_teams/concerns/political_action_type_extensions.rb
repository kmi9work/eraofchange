# Доступность политдействий, зависящих от технологий (п. 10).
module ManyTeams
  module Concerns
    module PoliticalActionTypeExtensions
      # Технология, без которой действие недоступно (по значению колонки action).
      TECHNOLOGY_GATES = {
        "lift_guild_embargoes" => 8 # Technology::OVERSEAS_TRADE («Заморская торговля»)
      }.freeze

      def many_teams_required_technology_id
        return nil unless ManyTeams.active?

        TECHNOLOGY_GATES[action.to_s]
      end

      def many_teams_technology_open?(country)
        technology_id = many_teams_required_technology_id
        return true if technology_id.nil?

        technology = ::Technology.find_by(id: technology_id)
        return false if technology.nil?

        technology.is_open(country) == 1
      end

      def many_teams_available_for?(country)
        many_teams_technology_open?(country)
      end
    end
  end
end
