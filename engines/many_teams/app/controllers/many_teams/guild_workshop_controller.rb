module ManyTeams
  # Данные для экранов предприятий в era_native (п. 6): где гильдии можно
  # добывать, где нельзя, и какие эмбарго на неё наложены.
  class GuildWorkshopController < BaseController
    NOTICE = "Обработка добычи и переработки предприятий ТОЛЬКО в программе".freeze

    # GET /many_teams/guilds/:guild_id/workshop
    def show
      guild = Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      countries = Country.order(:id).map do |country|
        {
          country_id: country.id,
          country_name: country.name,
          short_name: country.short_name,
          player_country: ManyTeams::PlayerCountry.buildable?(country),
          extraction_allowed: ManyTeams::GuildExtractionPermission.allowed?(guild, country),
          overridden: ManyTeams::GuildExtractionPermission.overridden?(guild, country),
          own: guild.country_id.to_i == country.id
        }
      end

      plants = guild.plants.includes(plant_level: { plant_type: :plant_category }, plant_place: :region).map do |plant|
        {
          plant_id: plant.id,
          plant_name: plant.plant_level&.plant_type&.name,
          extractive: !!plant.plant_level&.plant_type&.plant_category&.is_extractive,
          region_name: plant.plant_place&.region&.name,
          country_id: plant.plant_place&.region&.country_id,
          country_name: plant.plant_place&.region&.country&.name,
          extraction_forbidden: plant.many_teams_extraction_forbidden?
        }
      end

      render json: {
        notice: NOTICE,
        guild: { id: guild.id, name: guild.name, country_id: guild.country_id, country_name: guild.country&.name },
        year: GameParameter.current_year,
        countries: countries,
        plants: plants,
        forbidden_plant_ids: plants.select { |plant| plant[:extraction_forbidden] }.map { |plant| plant[:plant_id] },
        embargoes: ManyTeams::GuildEmbargo.for_guild(guild).includes(:country).map do |row|
          { country_id: row.country_id, country_name: row.country&.name, year: row.year }
        end
      }
    end
  end
end
