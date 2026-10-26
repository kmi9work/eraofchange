module ManyTeams
  # Разрешения гильдии в государстве: можно ли строить предприятия и работать
  # на них (п. 0-4) и действие Казначея, которым они меняются (п. 2).
  class GuildPermissionsController < BaseController
    # GET /many_teams/guild_permissions?country_id=12
    def index
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      render json: {
        country: {
          id: country.id,
          name: country.name,
          trades_on_market: country.trades_on_market?
        },
        guilds: ManyTeams::GuildCountryPermission.matrix_for(country)
      }
    end

    # POST /many_teams/guild_permissions
    # { guild_id, country_id, allowed } — выполняется действием Казначея.
    def update
      guild = Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      country = Country.find_by(id: params[:country_id])
      return render_error("Государство не найдено", :not_found) if country.nil?

      action, result = perform_action(
        "set_guild_permission",
        { "guild_id" => guild.id, "country_id" => country.id, "allowed" => !!ActiveModel::Type::Boolean.new.cast(params[:allowed]) }
      )

      render json: {
        action_id: action.id,
        guild_id: guild.id,
        country_id: country.id,
        allowed: ManyTeams::GuildCountryPermission.allowed?(guild, country),
        result: result
      }
    rescue ManyTeams::Error => e
      render_error(e.message)
    end
  end
end
