module ManyTeams
  # Разрешения на добычу «государство × гильдия» (п. 4) и действие Казначея,
  # которым они меняются (п. 5).
  class ExtractionPermissionsController < BaseController
    # GET /many_teams/extraction_permissions?country_id=12
    def index
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      render json: {
        country: { id: country.id, name: country.name },
        player_country_ids: ManyTeams::PlayerCountry.ids,
        guilds: ManyTeams::GuildExtractionPermission.matrix_for(country),
        countries: Country.order(:id).map { |item| { id: item.id, name: item.name, short_name: item.short_name } }
      }
    end

    # POST /many_teams/extraction_permissions
    # { guild_id, country_id, allowed } — выполняется действием Казначея.
    def update
      guild = Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      country = Country.find_by(id: params[:country_id])
      return render_error("Государство не найдено", :not_found) if country.nil?

      action, result = perform_action(
        "set_guild_extraction",
        { "guild_id" => guild.id, "country_id" => country.id, "allowed" => !!ActiveModel::Type::Boolean.new.cast(params[:allowed]) }
      )

      render json: {
        action_id: action.id,
        guild_id: guild.id,
        country_id: country.id,
        allowed: ManyTeams::GuildExtractionPermission.allowed?(guild, country),
        result: result
      }
    rescue ManyTeams::Error => e
      render_error(e.message)
    end
  end
end
