# Сводка по гильдиям государства для вкладки «Экономика → Дашборд».
#
# Гильдия принадлежит государству (`guilds.country_id`, Д11 ТЗ «несколько
# команд»), поэтому всё считается по гильдиям одного государства:
#   * предприятия — `plants` гильдии (полиморфная связь `economic_subject`);
#   * политические действия купцов — `political_actions.guild_id` (заполняется
#     в PoliticalActionsController для должности «Глава гульдии»);
#   * караваны — `caravans.guild_id`.
#
# «Возможный объём добычи/переработки» — это максимальный выпуск предприятия по
# формулам его уровня (`max_product` в `PlantLevel#formulas`), а не фактически
# произведённая продукция: `params['produced']` у Plant хранит только годы, когда
# предприятие работало. Добывающие и перерабатывающие предприятия разделяются по
# `PlantCategory#is_extractive`.
class GuildDashboardService
  def initialize(country, year: GameParameter.current_year)
    @country = country
    @year = year
    @resources = Resource.pluck(:identificator, :name, :icon).each_with_object({}) do |(identificator, name, icon), acc|
      acc[identificator] = { name: name, icon: icon }
    end
  end

  def as_json(*)
    guilds = Guild.where(country_id: @country.id).order(:name).to_a
    guild_ids = guilds.map(&:id)

    plants = load_plants(guild_ids)
    caravans = load_caravans(guild_ids)
    actions = load_actions(guild_ids)

    payloads = guilds.map do |guild|
      guild_payload(
        guild,
        plants[guild.id] || [],
        caravans[guild.id] || [],
        actions[guild.id] || []
      )
    end

    {
      country: country_payload,
      year: @year,
      guilds: payloads,
      totals: totals_payload(payloads)
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

  # ---- загрузка данных одним набором запросов (без N+1 по гильдиям) ----

  def load_plants(guild_ids)
    return {} if guild_ids.empty?

    Plant
      .where(economic_subject_type: 'Guild', economic_subject_id: guild_ids)
      .includes(plant_level: { plant_type: :plant_category }, plant_place: :region)
      .group_by(&:economic_subject_id)
  end

  def load_caravans(guild_ids)
    return {} if guild_ids.empty?

    Caravan
      .where(guild_id: guild_ids)
      .includes(:country)
      .order(year: :desc, created_at: :desc)
      .group_by(&:guild_id)
  end

  def load_actions(guild_ids)
    return {} if guild_ids.empty?

    PoliticalAction
      .where(guild_id: guild_ids)
      .includes(:political_action_type)
      .order(:created_at)
      .group_by(&:guild_id)
  end

  # ---- гильдия ----

  def guild_payload(guild, plants, caravans, actions)
    {
      id: guild.id,
      name: guild.name,
      icon: guild.respond_to?(:icon) ? guild.icon : nil,
      plants: plants_payload(plants),
      political_actions: actions_payload(actions),
      caravans: caravans_payload(caravans)
    }
  end

  # ---- предприятия ----

  def plants_payload(plants)
    by_type = plants.group_by { |plant| plant.plant_level&.plant_type }.map do |type, items|
      category = type&.plant_category

      {
        plant_type_id: type&.id,
        name: type&.name || 'Без типа',
        icon: type&.icon,
        category: category&.name,
        is_extractive: !!category&.is_extractive,
        count: items.size,
        levels: items.filter_map { |plant| plant.plant_level&.level }.uniq.sort,
        items: items.sort_by { |plant| [plant.plant_level&.level.to_i, plant.id] }
                   .map { |plant| plant_payload(plant) }
      }
    end.sort_by { |type| [-type[:count], type[:name].to_s] }

    extractive, processing = plants.partition do |plant|
      plant.plant_level&.plant_type&.plant_category&.is_extractive
    end

    {
      total: plants.size,
      by_type: by_type,
      # Суммарный возможный выпуск по ресурсам (по всем предприятиям гильдии)
      extraction: resources_from_plants(extractive),
      processing: resources_from_plants(processing)
    }
  end

  def plant_payload(plant)
    level = plant.plant_level
    type = level&.plant_type
    place = plant.plant_place
    region = place&.region
    location = [region&.name, place&.name].compact.uniq.join(' / ')

    {
      id: plant.id,
      plant_type: type&.name,
      comments: plant.comments,
      level: level&.level,
      deposit: level&.deposit,
      place: place&.name,
      region: region&.name,
      location: location.presence,
      output: formula_resources(level&.formulas, 'max_product'),
      input: formula_resources(level&.formulas, 'from')
    }
  end

  def resources_from_plants(plants)
    sums = Hash.new(0)

    plants.each do |plant|
      formula_resources(plant.plant_level&.formulas, 'max_product').each do |resource|
        sums[resource[:identificator]] += resource[:count]
      end
    end

    resource_list(sums)
  end

  # ---- политические действия ----

  def actions_payload(actions)
    year_actions = actions.select { |action| action.year == @year }

    {
      performed: year_actions.any?,
      count: year_actions.size,
      items: year_actions.sort_by(&:created_at).map do |action|
        {
          id: action.id,
          name: action.political_action_type&.name,
          action: action.political_action_type&.action,
          success: action.success,
          params: action.params,
          created_at: action.created_at
        }
      end
    }
  end

  # ---- караваны ----

  def caravans_payload(caravans)
    {
      year: caravan_group(caravans.select { |caravan| caravan.year == @year }),
      all_time: caravan_group(caravans)
    }
  end

  # Ограбленные караваны показываются в списке, но не входят в товарооборот,
  # ресурсы и разбивку по странам: груз до страны не дошёл (та же логика, что в
  # Caravan.count_caravan_revenue и статистике мастеров).
  def caravan_group(caravans)
    arrived = caravans.reject(&:is_robbed)

    {
      count: caravans.size,
      robbed_count: caravans.count(&:is_robbed),
      gold_export: arrived.sum { |caravan| caravan.gold_export.to_i.abs },
      gold_import: arrived.sum { |caravan| caravan.gold_import.to_i.abs },
      turnover: arrived.sum { |caravan| caravan.gold_export.to_i.abs + caravan.gold_import.to_i.abs },
      resources_export: caravan_resources(arrived, :resources_export),
      resources_import: caravan_resources(arrived, :resources_import),
      by_country: caravans_by_country(arrived),
      items: caravans.map { |caravan| caravan_payload(caravan) }
    }
  end

  def caravans_by_country(caravans)
    caravans.group_by(&:country_id).map do |country_id, items|
      country = items.first&.country

      {
        country_id: country_id,
        name: country&.name || "Государство ##{country_id}",
        short_name: country&.short_name,
        flag_image_name: country&.flag_image_name,
        count: items.size,
        gold_export: items.sum { |caravan| caravan.gold_export.to_i.abs },
        gold_import: items.sum { |caravan| caravan.gold_import.to_i.abs },
        turnover: items.sum { |caravan| caravan.gold_export.to_i.abs + caravan.gold_import.to_i.abs },
        resources_export: caravan_resources(items, :resources_export),
        resources_import: caravan_resources(items, :resources_import)
      }
    end.sort_by { |row| -row[:turnover] }
  end

  def caravan_payload(caravan)
    {
      id: caravan.id,
      year: caravan.year,
      country_id: caravan.country_id,
      country: caravan.country&.name,
      flag_image_name: caravan.country&.flag_image_name,
      gold_export: caravan.gold_export.to_i.abs,
      gold_import: caravan.gold_import.to_i.abs,
      turnover: caravan.gold_export.to_i.abs + caravan.gold_import.to_i.abs,
      resources_export: normalize_resource_rows(caravan.resources_export),
      resources_import: normalize_resource_rows(caravan.resources_import),
      is_robbed: !!caravan.is_robbed,
      via_vyatka: !!caravan.via_vyatka,
      created_at: caravan.created_at
    }
  end

  def caravan_resources(caravans, key)
    sums = Hash.new(0)

    caravans.each do |caravan|
      normalize_resource_rows(caravan.public_send(key)).each do |resource|
        sums[resource[:identificator]] += resource[:count]
      end
    end

    resource_list(sums)
  end

  # ---- ресурсы ----

  # Ресурсы из формул уровня: `max_product` — предельный выпуск, `from` — расход.
  def formula_resources(formulas, key)
    sums = Hash.new(0)

    Array(formulas).each do |formula|
      next unless formula.respond_to?(:[])

      value = formula[key]
      rows = value.is_a?(Hash) ? [value] : Array(value)

      rows.each do |resource|
        next unless resource.respond_to?(:[])

        identificator = (resource['identificator'] || resource[:identificator]).to_s
        next if identificator.blank?

        sums[identificator] += (resource['count'] || resource[:count]).to_i
      end
    end

    resource_list(sums)
  end

  def normalize_resource_rows(value)
    rows = value.is_a?(Hash) ? [value] : Array(value)
    sums = Hash.new(0)

    rows.each do |resource|
      next unless resource.respond_to?(:[])

      identificator = (resource['identificator'] || resource[:identificator]).to_s
      next if identificator.blank?

      sums[identificator] += (resource['count'] || resource[:count]).to_i
    end

    resource_list(sums)
  end

  def resource_list(sums)
    sums.sort_by { |identificator, _count| resource_name(identificator).to_s }
        .map do |identificator, count|
          {
            identificator: identificator,
            name: resource_name(identificator),
            icon: resource_icon(identificator),
            count: count
          }
        end
  end

  def resource_name(identificator)
    @resources.dig(identificator, :name) || identificator
  end

  # Имя файла иконки: /images/resources/<icon>.png (обычно совпадает с identificator)
  def resource_icon(identificator)
    @resources.dig(identificator, :icon).presence || identificator
  end

  # ---- итоги по государству ----

  def totals_payload(payloads)
    {
      guilds: payloads.size,
      plants: payloads.sum { |guild| guild[:plants][:total] },
      extraction: merge_resource_lists(payloads.map { |guild| guild[:plants][:extraction] }),
      processing: merge_resource_lists(payloads.map { |guild| guild[:plants][:processing] }),
      guilds_with_political_actions: payloads.count { |guild| guild[:political_actions][:performed] },
      political_actions: payloads.sum { |guild| guild[:political_actions][:count] },
      caravans: payloads.sum { |guild| guild[:caravans][:year][:count] },
      turnover: payloads.sum { |guild| guild[:caravans][:year][:turnover] }
    }
  end

  def merge_resource_lists(lists)
    sums = Hash.new(0)

    lists.each do |list|
      list.each { |resource| sums[resource[:identificator]] += resource[:count] }
    end

    resource_list(sums)
  end
end
