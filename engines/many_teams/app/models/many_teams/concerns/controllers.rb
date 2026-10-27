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
    #
    # Технологии (сейчас «Ремесловые люди» → кузница/ювелирная мастерская) в
    # многострановом режиме тоже считаются ПО ГОСУДАРСТВУ ЗЕМЛИ, а не по
    # `Country.current` ядра: гильдия Москвы может строить в Орде, и там
    # технология может быть открыта. Поэтому:
    #  * у места появляется `technology_requirements` со статусом технологии в
    #    государстве этой земли;
    #  * у типа появляется `open_anywhere` — открыта ли технология хотя бы в
    #    одном государстве, где гильдии разрешено строительство. Только по нему
    #    клиент рисует «технология не открыта» на экране выбора типа.
    # Прежнее поле `open` не меняется (статус текущего государства) — на него
    # опираются остальные клиенты.
    module PlantPlacesControllerExtensions
      def available_places
        super
        return unless ManyTeams.active?

        payload = JSON.parse(response.body) rescue nil
        return if payload.nil? || !payload.is_a?(Array)

        guild = ::Guild.find_by(id: params[:guild_id])
        countries = ::Country.all.index_by(&:id)
        technologies = ::Technology.all.index_by(&:id)
        # Страны, где этой гильдии разрешено строительство (умолчание + переопределения).
        build_countries = guild ? guild.many_teams_build_countries : [::Country.current].compact
        open_cache = {}

        tech_open_in = lambda do |technology, country|
          next false if technology.nil? || country.nil?

          open_cache.fetch([technology.id, country.id]) do
            open_cache[[technology.id, country.id]] = technology.is_open(country).to_i == 1
          end
        end

        payload.each do |type|
          requirements = Array(type["technology_requirements"])

          Array(type["available_places"]).each do |place|
            country = countries[place["region_country_id"].to_i] if place["region_country_id"]
            place["country_name"] = country&.name

            # Статус технологии — в государстве земли; без государства оставляем
            # значение ядра (оно посчитано по текущему государству).
            unless requirements.empty?
              place["technology_requirements"] = requirements.map do |requirement|
                technology = technologies[requirement["id"].to_i]
                requirement.merge(
                  "open" => country ? tech_open_in.call(technology, country) : requirement["open"]
                )
              end
            end

            # Без гильдии запрета нет: правило считается по паре «гильдия ×
            # государство», поэтому ответ ядра (allowed) не перетираем.
            next if guild.nil? || country.nil?

            place["allowed"] = ManyTeams::GuildCountryPermission.allowed?(guild, country)
          end

          # «Технология не открыта» на экране выбора типа — только если нет ни
          # одной страны, где гильдии разрешено строить и технология открыта.
          requirements.each do |requirement|
            technology = technologies[requirement["id"].to_i]
            requirement["open_anywhere"] = build_countries.any? do |country|
              tech_open_in.call(technology, country)
            end
          end
        end

        response.body = payload.to_json
      end
    end
  end
end
