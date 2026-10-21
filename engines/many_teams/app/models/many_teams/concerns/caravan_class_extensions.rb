# Эмбарго иностранного государства на гильдию (п. 9): караван этой гильдии в
# это государство не регистрируется — как и при страновом флаге
# Country#params["embargo"], обойти можно карточкой «Контрабанда» за текущий год.
#
# Маршрут через Вятку остаётся прежним обходом: страновой флаг его тоже не
# проверяет (см. Caravan.register_caravan), поэтому и гильдейское эмбарго здесь
# не проверяется.
module ManyTeams
  module Concerns
    module CaravanClassExtensions
      def register_caravan(params)
        return super unless ManyTeams.active?

        via_vyatka = params[:via_vyatka] == true || params[:via_vyatka] == 'true' || params[:via_vyatka] == 1
        return super if via_vyatka

        guild_id = params[:guild_id].to_i
        if guild_id.positive?
          country = ::Country.find_by(id: params[:country_id])
          guild = ::Guild.find_by(id: guild_id)
          year = GameParameter.current_year
          if country && guild &&
             ManyTeams::GuildEmbargo.embargoed?(country, guild) &&
             !guild.has_contraband_card?(year)
            return {
              success: false,
              error: "На гильдию «#{guild.name}» наложено эмбарго государством «#{country.name}». " \
                     "Для торговли необходима карточка Контрабанда."
            }
          end
        end

        super
      end
    end
  end
end
