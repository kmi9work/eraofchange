# Точки расширения контроллеров ядра.
module ManyTeams
  module Concerns
    # /plant_places/available_places: в режиме many_teams место помечается
    # запретом гильдии (п. 0-1): `allowed` = можно ли этой гильдии строить и
    # работать в государстве места. Правило одно для всех категорий предприятий,
    # гильдия приходит параметром `?guild_id=`; без него запрета нет.
    #
    # Других запретов на предприятия в режиме many_teams нет (решение заказчика):
    # правило «строить только в государствах игроков» из предприятий убрано.
    module PlantPlacesControllerExtensions
      def available_places
        super
        return unless ManyTeams.active?

        payload = JSON.parse(response.body) rescue nil
        return if payload.nil? || !payload.is_a?(Array)

        guild = ::Guild.find_by(id: params[:guild_id])

        payload.each do |type|
          Array(type["available_places"]).each do |place|
            country = ::Country.find_by(id: place["region_country_id"])
            place["country_name"] = country&.name

            # Без гильдии запрета нет: правило считается по паре «гильдия ×
            # государство», поэтому ответ ядра (allowed) не перетираем.
            next if guild.nil? || country.nil?

            place["allowed"] = ManyTeams::GuildCountryPermission.allowed?(guild, country)
          end
        end

        response.body = payload.to_json
      end
    end
  end
end
