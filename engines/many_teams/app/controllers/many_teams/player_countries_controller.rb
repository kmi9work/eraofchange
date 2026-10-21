module ManyTeams
  # Государства игроков, подтверждённые на «Дашборде» (п. 7).
  class PlayerCountriesController < BaseController
    # GET /many_teams/player_countries
    def index
      render json: payload
    end

    # PATCH /many_teams/player_countries { country_ids: [1, 5] }
    def update
      ManyTeams::PlayerCountry.replace!(params[:country_ids])
      render json: payload
    end

    private

    def payload
      ids = ManyTeams::PlayerCountry.ids
      {
        country_ids: ids,
        countries: Country.order(:id).map do |country|
          {
            id: country.id,
            name: country.name,
            short_name: country.short_name,
            flag_image_name: country.flag_image_name,
            confirmed: ids.include?(country.id)
          }
        end
      }
    end
  end
end
