module ManyTeams
  # Эмбарго страны на гильдию (п. 9) и снятие всех эмбарго Великим князем (п. 10).
  class GuildEmbargoesController < BaseController
    # GET /many_teams/guild_embargoes?country_id=12
    # Страна в параметре — та, что накладывает эмбарго.
    def index
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      render json: {
        country: { id: country.id, name: country.name },
        countries: Country.order(:id).map { |item| { id: item.id, name: item.name, short_name: item.short_name } },
        guilds: Guild.order(:name).map { |guild| guild_row(country, guild) }
      }
    end

    # POST /many_teams/guild_embargoes { country_id, guild_id }
    def create
      country = Country.find_by(id: params[:country_id]) || Country.current
      guild = Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      ManyTeams::GuildEmbargo.impose!(country, guild, comment: "Эмбарго государства «#{country.name}»")
      render json: { country_id: country.id, guild_id: guild.id, embargoed: true }
    end

    # DELETE /many_teams/guild_embargoes { country_id, guild_id }
    def destroy
      country = Country.find_by(id: params[:country_id]) || Country.current
      guild = Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      ManyTeams::GuildEmbargo.lift!(country, guild)
      render json: { country_id: country.id, guild_id: guild.id, embargoed: false }
    end

    # POST /many_teams/guild_embargoes/impose_all
    # { country_id (кто накладывает), target_country_id (на все гильдии какой страны) }
    def impose_all
      country = Country.find_by(id: params[:country_id]) || Country.current
      target = Country.find_by(id: params[:target_country_id])
      return render_error("Государство не найдено", :not_found) if country.nil? || target.nil?

      rows = ManyTeams::GuildEmbargo.impose_country_on_all!(
        country, target, comment: "Эмбарго «#{country.name}» на гильдии «#{target.name}»"
      )

      render json: {
        country_id: country.id,
        target_country_id: target.id,
        guild_ids: rows.map(&:guild_id),
        count: rows.size
      }
    end

    # POST /many_teams/guild_embargoes/lift_all { guild_id }
    # Требует открытой технологии «Заморская торговля» у текущего государства —
    # это действие Великого князя (п. 10).
    def lift_all
      guild = Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      action, result = perform_action("lift_guild_embargoes", { "guild_id" => guild.id })
      render json: { action_id: action.id, guild_id: guild.id, lifted_country_ids: result[:lifted_country_ids] }
    rescue ManyTeams::Error => e
      render_error(e.message)
    end

    private

    def guild_row(country, guild)
      embargo = ManyTeams::GuildEmbargo.find_by(country_id: country.id, guild_id: guild.id)
      {
        id: guild.id,
        name: guild.name,
        country_id: guild.country_id,
        country_name: guild.country&.name,
        embargoed: !embargo.nil?,
        embargo_year: embargo&.year,
        embargoes: ManyTeams::GuildEmbargo.for_guild(guild).includes(:country).map do |row|
          { country_id: row.country_id, country_name: row.country&.name, year: row.year }
        end
      }
    end
  end
end
