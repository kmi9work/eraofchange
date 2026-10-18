module ManyTeams
  # Эмбарго на гильдии (п. 9) и снятие всех эмбарго Великим князем (п. 10).
  #
  # Направление — как в правилах игры (dizdoc, п. 9): накладывает иностранное
  # государство (country_id), цель — гильдии другого государства
  # (target_country_id). Накладывать может только государство, торгующее на
  # рынке: у Руси и русских княжеств своих товаров на «Рынке» нет.
  class GuildEmbargoesController < BaseController
    IMPOSER_NOT_TRADING = "Эмбарго на гильдии может наложить только государство, торгующее на рынке".freeze

    # GET /many_teams/guild_embargoes?country_id=3&target_country_id=1
    # country_id — кто накладывает; target_country_id (необязательный) — чьи
    # гильдии показывать. Без него отдаются все гильдии, как раньше.
    def index
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      target = nil
      if params[:target_country_id].present?
        target = Country.find_by(id: params[:target_country_id])
        return render_error("Государство не найдено", :not_found) if target.nil?
      end

      guilds = target ? ::Guild.where(country_id: target.id) : ::Guild

      render json: {
        country: country_row(country),
        target_country: target && { id: target.id, name: target.name, short_name: target.short_name },
        countries: Country.order(:id).map { |item| { id: item.id, name: item.name, short_name: item.short_name } },
        guilds: guilds.order(:name).map { |guild| guild_row(country, guild) }
      }
    end

    # POST /many_teams/guild_embargoes { country_id, guild_id }
    def create
      country = imposer
      return render_error("Государство не найдено", :not_found) if country.nil?
      return render_error(IMPOSER_NOT_TRADING) unless country.trades_on_market?

      guild = ::Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      ManyTeams::GuildEmbargo.impose!(country, guild, comment: "Эмбарго государства «#{country.name}»")
      render json: { country_id: country.id, guild_id: guild.id, embargoed: true }
    end

    # DELETE /many_teams/guild_embargoes { country_id, guild_id }
    # Снимать можно всегда: если государство перестало торговать на рынке,
    # старые эмбарго всё равно нужно уметь отменить.
    def destroy
      country = imposer
      return render_error("Государство не найдено", :not_found) if country.nil?

      guild = ::Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      ManyTeams::GuildEmbargo.lift!(country, guild)
      render json: { country_id: country.id, guild_id: guild.id, embargoed: false }
    end

    # POST /many_teams/guild_embargoes/impose_all
    # { country_id (кто накладывает), target_country_id (на все гильдии какой страны) }
    def impose_all
      country = imposer
      return render_error("Государство не найдено", :not_found) if country.nil?
      return render_error(IMPOSER_NOT_TRADING) unless country.trades_on_market?

      target = Country.find_by(id: params[:target_country_id])
      return render_error("Государство не найдено", :not_found) if target.nil?

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

    # POST /many_teams/guild_embargoes/lift_all_for_country
    # { country_id (кто наложил), target_country_id (с гильдий какой страны снять) }
    def lift_all_for_country
      country = imposer
      return render_error("Государство не найдено", :not_found) if country.nil?

      target = Country.find_by(id: params[:target_country_id])
      return render_error("Государство не найдено", :not_found) if target.nil?

      guild_ids = ::Guild.where(country_id: target.id).select(:id)
      count = ManyTeams::GuildEmbargo.where(country_id: country.id, guild_id: guild_ids).delete_all

      render json: { country_id: country.id, target_country_id: target.id, count: count }
    end

    # POST /many_teams/guild_embargoes/lift_all { guild_id }
    # Действие Великого князя (п. 10): снимает все эмбарго с гильдии.
    # Технология «Заморская торговля» его НЕ блокирует (решение заказчика):
    # закрытая технология только помечается в params политдействия.
    def lift_all
      guild = ::Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      action, result = perform_action("lift_guild_embargoes", { "guild_id" => guild.id })
      render json: {
        action_id: action.id,
        guild_id: guild.id,
        lifted_country_ids: result[:lifted_country_ids],
        overseas_trade_open: result[:overseas_trade_open]
      }
    rescue ManyTeams::Error => e
      render_error(e.message)
    end

    # GET /many_teams/guild_embargoes/lift_all_availability
    # Статус условия технологии «Заморская торговля» для п. 10: клиент показывает
    # предупреждение «действие запрещено», но само действие не блокирует.
    def lift_all_availability
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      technology = ManyTeams::GuildEmbargo.overseas_trade_technology

      render json: {
        country_id: country.id,
        country_name: country.name,
        technology_id: technology&.id,
        technology_name: ManyTeams::GuildEmbargo.overseas_trade_name,
        is_open: ManyTeams::GuildEmbargo.overseas_trade_open?(country)
      }
    end

    # GET /many_teams/guild_embargoes/market?guild_id=1&country_id=1
    # Состояние «Рынка»: какие государства наложили эмбарго на конкретную
    # гильдию. Заменяет страновой флаг Country#params["embargo"], который
    # относится к стране целиком и к гильдиям отношения не имеет.
    def market
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      guild = ::Guild.find_by(id: params[:guild_id])
      return render_error("Гильдия не найдена", :not_found) if guild.nil?

      embargoed_ids = ManyTeams::GuildEmbargo.for_guild(guild).pluck(:country_id)

      render json: {
        country: country_row(country),
        guild: {
          id: guild.id,
          name: guild.name,
          country_id: guild.country_id,
          country_name: guild.country&.name
        },
        countries: Country.order(:id).map do |item|
          {
            id: item.id,
            name: item.name,
            short_name: item.short_name,
            trades_on_market: item.trades_on_market?,
            embargoed: embargoed_ids.include?(item.id)
          }
        end
      }
    end

    private

    def imposer
      Country.find_by(id: params[:country_id]) || Country.current
    end

    def country_row(country)
      {
        id: country.id,
        name: country.name,
        short_name: country.short_name,
        trades_on_market: country.trades_on_market?
      }
    end

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
