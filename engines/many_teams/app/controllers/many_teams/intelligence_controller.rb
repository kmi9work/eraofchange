module ManyTeams
  # Справочник пунктов разведки для экрана Тайного советника (п. 11).
  class IntelligenceController < BaseController
    # GET /many_teams/intelligence/targets
    def targets
      rival_ids = ManyTeams::PlayerCountry.ids.reject { |id| id == Country.current&.id }

      render json: {
        intel_kinds: ManyTeams::IntelligenceService.kinds,
        player_country_ids: ManyTeams::PlayerCountry.ids,
        rival_countries: Country.where(id: rival_ids).order(:name).map do |country|
          { id: country.id, name: country.name, short_name: country.short_name }
        end,
        countries: Country.order(:id).map { |country| { id: country.id, name: country.name, short_name: country.short_name } },
        regions: Region.where(country_id: Country.current&.id).order(:name).map do |region|
          { id: region.id, name: region.name, country_id: region.country_id }
        end,
        guilds: Guild.order(:name).map do |guild|
          { id: guild.id, name: guild.name, country_id: guild.country_id, country_name: guild.country&.name }
        end
      }
    end
  end
end
