module ManyTeams
  # Справочник пунктов разведки для экрана Тайного советника (п. 11).
  class IntelligenceController < BaseController
    # GET /many_teams/intelligence/targets
    #
    # Регионы отдаются только по странам-соперникам (государства игроков,
    # подтверждённые на «Дашборде», кроме текущего): и «Общественный порядок»,
    # и «Подорвать стабильность» бьют по чужой земле.
    def targets
      rival_ids = ManyTeams::IntelligenceService.rival_country_ids

      render json: {
        intel_kinds: ManyTeams::IntelligenceService.kinds,
        player_country_ids: ManyTeams::PlayerCountry.ids,
        rival_countries: Country.where(id: rival_ids).order(:name).map do |country|
          { id: country.id, name: country.name, short_name: country.short_name }
        end,
        countries: Country.order(:id).map { |country| { id: country.id, name: country.name, short_name: country.short_name } },
        regions: ManyTeams::IntelligenceService.rival_regions.map do |region|
          {
            id: region.id,
            name: region.name,
            country_id: region.country_id,
            country_name: region.country&.name,
            country_short_name: region.country&.short_name
          }
        end,
        guilds: Guild.order(:name).map do |guild|
          { id: guild.id, name: guild.name, country_id: guild.country_id, country_name: guild.country&.name }
        end
      }
    end
  end
end
