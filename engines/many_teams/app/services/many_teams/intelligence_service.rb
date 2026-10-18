# Разведка Тайного советника (п. 11).
#
# Действие одно, а пунктов разведки четыре, у каждого своя цена. Отчёт считается
# на бэкенде и складывается в params политдействия («report»), поэтому клиент
# показывает уже посчитанные данные, а не собирает их сам.
module ManyTeams
  class IntelligenceService
    KINDS = {
      "public_order" => { price: 1000, title: "Общественный порядок в регионе" },
      "rival_relations" => { price: 1000, title: "Отношения команды-соперника с державой" },
      "noble_income" => { price: 3000, title: "Доход знати команды-соперника" },
      "technologies" => { price: 3000, title: "Открытые технологии команды-соперника" }
    }.freeze

    def self.kinds
      KINDS.map { |key, value| value.merge(intel_type: key) }
    end

    def self.price_for(kind)
      KINDS.dig(kind.to_s, :price) || KINDS["public_order"][:price]
    end

    def initialize(action)
      @action = action
      @params = action.params || {}
    end

    def report
      kind = (@params["intel_type"] || @params[:intel_type]).to_s
      config = KINDS[kind]
      raise ManyTeams::Error, "Неизвестный пункт разведки: #{kind.inspect}" if config.nil?

      {
        "intel_type" => kind,
        "title" => config[:title],
        "price" => config[:price],
        "year" => @action.year || GameParameter.current_year,
        "data" => send("report_#{kind}")
      }
    end

    # Пара государств для действия «подорвать отношения».
    # По умолчанию первое государство — зарубежное, второе — текущее (п. 11).
    def relation_pair
      first = ::Country.find_by(id: param(:country_a_id))
      second = ::Country.find_by(id: param(:country_b_id))
      current = Country.current

      first ||= ::Country.foreign_countries.order(:id).first || ::Country.except_country(current).order(:id).first
      second ||= current

      raise ManyTeams::Error, "Не найдено государство для пары" if first.nil? || second.nil?
      raise ManyTeams::Error, "Пара государств должна быть разной" if first.id == second.id

      [first, second]
    end

    private

    def param(key)
      @params[key.to_s] || @params[key.to_sym]
    end

    # Команда-соперник: государство игроков, отличное от текущего.
    def rival_country
      @rival_country ||= begin
        explicit = ::Country.find_by(id: param(:rival_country_id))
        explicit || ManyTeams::PlayerCountry.ids
                                       .reject { |id| id == Country.current&.id }
                                       .map { |id| ::Country.find_by(id: id) }
                                       .compact
                                       .first ||
          ::Country.except_country(Country.current).order(:id).first
      end
    end

    def require_rival!
      raise ManyTeams::Error, "Команда-соперник не определена" if rival_country.nil?

      rival_country
    end

    def report_public_order
      # Регион выбирает игрок; если не выбрал — берём первый регион текущего
      # государства, чтобы отчёт строился и при вызове из API без параметра.
      region = ::Region.find_by(id: param(:region_id)) ||
               ::Region.where(country_id: Country.current&.id).order(:id).first ||
               ::Region.order(:id).first
      raise ManyTeams::Error, "Регион не найден" if region.nil?

      {
        "region_id" => region.id,
        "region_name" => region.name,
        "country_id" => region.country_id,
        "country_name" => region.country&.name,
        "public_order" => region.show_overall_po(region.country || Country.current)
      }
    end

    def report_rival_relations
      rival = require_rival!
      partner = ::Country.find_by(id: param(:country_id))

      rows = (partner ? [partner] : ::Country.except_country(rival).order(:id).to_a).map do |country|
        {
          "country_id" => country.id,
          "country_name" => country.name,
          "short_name" => country.short_name,
          "relations" => rival.relations_with(country)
        }
      end

      {
        "rival_country_id" => rival.id,
        "rival_country_name" => rival.name,
        "relations" => rows
      }
    end

    def report_noble_income
      rival = require_rival!
      year = GameParameter.current_year
      noble_type = ::PlayerType.find_by(name: "Знать")
      nobles = rival.players
      nobles = nobles.where(player_type_id: noble_type.id) if noble_type
      nobles = nobles.order(:name).to_a

      rows = nobles.map do |noble|
        income = ::IncomeItem.where(player_id: noble.id, year: year).sum(:value)
        {
          "player_id" => noble.id,
          "name" => noble.name,
          "income" => income
        }
      end

      {
        "rival_country_id" => rival.id,
        "rival_country_name" => rival.name,
        "year" => year,
        "nobles" => rows,
        "total" => rows.sum { |row| row["income"] }
      }
    end

    def report_technologies
      rival = require_rival!
      open_items = ::TechnologyItem.where(country_id: rival.id, value: 1)
      technologies = ::Technology.where(id: open_items.select(:technology_id)).order(:id)

      {
        "rival_country_id" => rival.id,
        "rival_country_name" => rival.name,
        "technologies" => technologies.map do |technology|
          { "id" => technology.id, "name" => technology.name, "description" => technology.description }
        end
      }
    end
  end
end
