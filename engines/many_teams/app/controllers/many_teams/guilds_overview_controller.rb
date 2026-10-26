module ManyTeams
  # Окно «Служебное → Гильдии»: табло мастеров со всеми гильдиями игры —
  # разрешение на строительство/производство в текущем государстве, эмбарго и
  # ресурсы, добываемые/производимые на его территории. Только чтение.
  class GuildsOverviewController < BaseController
    # GET /many_teams/guilds_overview?country_id=12
    def index
      country = requested_country
      return render_error("Государство не найдено", :not_found) if country.nil?

      render json: ManyTeams::GuildsOverview.new(country).as_json
    end
  end
end
