# Точки расширения контроллеров ядра.
module ManyTeams
  module Concerns
    # /plant_places/available_places: в режиме many_teams место доступно, если
    # государство региона — государство игроков, а для добывающих предприятий
    # дополнительно проверяется разрешение гильдии (?guild_id=).
    module PlantPlacesControllerExtensions
      def available_places
        super
        return unless ManyTeams.active?

        payload = JSON.parse(response.body) rescue nil
        return if payload.nil? || !payload.is_a?(Array)

        guild = ::Guild.find_by(id: params[:guild_id])

        payload.each do |type|
          types = ::PlantType.find_by(id: type["plant_type_id"])
          extractive = !!types&.plant_category&.is_extractive

          Array(type["available_places"]).each do |place|
            country = ::Country.find_by(id: place["region_country_id"])
            player_country = country.present? && ManyTeams::PlayerCountry.buildable?(country)

            place["player_country"] = player_country
            place["allowed"] = player_country
            place["extraction_allowed"] =
              if extractive && guild && country
                ManyTeams::GuildExtractionPermission.allowed?(guild, country)
              else
                true
              end
            place["country_name"] = country&.name
          end
        end

        response.body = payload.to_json
      end
    end

  end
end
