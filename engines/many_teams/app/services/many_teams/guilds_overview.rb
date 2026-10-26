# Табло «все гильдии игры» для окна «Служебное → Гильдии».
#
# Экран мастеров, только чтение. По каждой гильдии:
#   * разрешено ли строительство и работа предприятий на территории ТЕКУЩЕГО
#     государства (`ManyTeams::GuildCountryPermission`, п. 0-2 — то же правило,
#     что отдаёт `/plant_places/available_places` и цех гильдии);
#   * какие государства наложили на гильдию эмбарго (п. 9);
#   * какие ресурсы гильдия добывает/производит на территории текущего
#     государства — значки без количества: выпуск (`max_product`) предприятий
#     гильдии, чей участок (`plant_place.region`) лежит в этом государстве;
#   * товарооборот гильдии по странам за всю игру (караваны, ограбленные не
#     считаются) — герб страны и число. Остальные столбцы — текущее состояние.
#
# Считается по ВСЕМ гильдиям игры, а не только по гильдиям государства, в отличие
# от `GuildDashboardService` («Экономика → Дашборд»).
module ManyTeams
  class GuildsOverview
    def initialize(country)
      @country = country
      @resources = ::Resource.pluck(:identificator, :name, :icon).each_with_object({}) do |(identificator, name, icon), acc|
        acc[identificator] = { name: name, icon: icon }
      end
    end

    def as_json(*)
      guilds = ::Guild.includes(:country).order(:name).to_a
      guild_ids = guilds.map(&:id)

      permissions = ::ManyTeams::GuildCountryPermission
                    .where(country_id: @country.id, guild_id: guild_ids)
                    .index_by(&:guild_id)
      embargoes = ::ManyTeams::GuildEmbargo
                  .where(guild_id: guild_ids)
                  .includes(:country)
                  .group_by(&:guild_id)
      plants = plants_for(guild_ids)
      caravans = caravans_for(guild_ids)

      {
        country: country_payload,
        year: ::GameParameter.current_year,
        guilds: guilds.map do |guild|
          guild_payload(
            guild,
            permissions[guild.id],
            embargoes[guild.id] || [],
            plants[guild.id] || [],
            caravans[guild.id] || []
          )
        end
      }
    end

    private

    def country_payload
      {
        id: @country.id,
        name: @country.name,
        short_name: @country.short_name,
        flag_image_name: @country.flag_image_name
      }
    end

    # Предприятия всех гильдий одним запросом; регион участка нужен, чтобы
    # отобрать только территорию текущего государства.
    def plants_for(guild_ids)
      return {} if guild_ids.empty?

      ::Plant
        .where(economic_subject_type: 'Guild', economic_subject_id: guild_ids)
        .includes(plant_level: { plant_type: :plant_category }, plant_place: :region)
        .group_by(&:economic_subject_id)
    end

    def guild_payload(guild, permission, embargo_rows, plants, caravans)
      {
        guild_id: guild.id,
        guild_name: guild.name,
        guild_country_id: guild.country_id,
        guild_country_name: guild.country&.name,
        guild_country_flag: guild.country&.flag_image_name,
        own: guild.country_id.to_i == @country.id,
        allowed: permission.nil? ? ::ManyTeams::GuildCountryPermission.default_allowed?(guild, @country) : permission.allowed?,
        overridden: !permission.nil?,
        embargoes: embargoes_payload(embargo_rows),
        resources: resources_payload(plants),
        turnover: turnover_payload(caravans)
      }
    end

    # Караваны за всю игру: товарооборот гильдии по странам. Ограбленные
    # караваны не считаются (груз до страны не дошёл) — как в
    # `GuildDashboardService` и статистике мастеров.
    def caravans_for(guild_ids)
      return {} if guild_ids.empty?

      ::Caravan
        .where(guild_id: guild_ids, is_robbed: false)
        .includes(:country)
        .group_by(&:guild_id)
    end

    # Товарооборот по странам: герб + сумма |вывоз| + |ввоз|.
    def turnover_payload(caravans)
      caravans
        .group_by(&:country_id)
        .map do |country_id, rows|
          country = rows.first&.country

          {
            country_id: country_id,
            country_name: country&.name || "Государство ##{country_id}",
            short_name: country&.short_name,
            flag_image_name: country&.flag_image_name,
            turnover: rows.sum { |caravan| caravan.gold_export.to_i.abs + caravan.gold_import.to_i.abs }
          }
        end
        .sort_by { |row| -row[:turnover] }
    end

    def embargoes_payload(rows)
      rows
        .sort_by { |row| row.country&.name.to_s }
        .map do |row|
          {
            country_id: row.country_id,
            country_name: row.country&.name,
            short_name: row.country&.short_name,
            flag_image_name: row.country&.flag_image_name,
            year: row.year
          }
        end
    end

    # Только значки: имя и файл иконки, без количества.
    def resources_payload(plants)
      identificators = plants.filter_map do |plant|
        next unless plant.plant_place&.region&.country_id.to_i == @country.id

        formula_resources(plant.plant_level&.formulas)
      end.flatten.uniq

      identificators
        .sort_by { |identificator| resource_name(identificator).to_s }
        .map do |identificator|
          {
            identificator: identificator,
            name: resource_name(identificator),
            icon: resource_icon(identificator)
          }
        end
    end

    # Ресурсы выпуска из формул уровня (`max_product`). Формула может хранить как
    # один хэш, так и массив — как в `GuildDashboardService`.
    def formula_resources(formulas)
      Array(formulas).flat_map do |formula|
        next [] unless formula.respond_to?(:[])

        value = formula['max_product'] || formula[:max_product]
        rows = value.is_a?(Hash) ? [value] : Array(value)

        rows.filter_map do |resource|
          next unless resource.respond_to?(:[])

          (resource['identificator'] || resource[:identificator]).presence
        end
      end
    end

    def resource_name(identificator)
      @resources.dig(identificator, :name) || identificator
    end

    def resource_icon(identificator)
      @resources.dig(identificator, :icon).presence || identificator
    end
  end
end
