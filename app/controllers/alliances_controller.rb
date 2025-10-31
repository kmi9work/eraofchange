class AlliancesController < ApplicationController
  before_action :set_alliance, only: [:destroy]

  # GET /countries/:country_id/alliances.json
  def index
    country = Country.find(params[:country_id])
    @alliances = country.alliances.includes(:partner_country, :alliance_type)
    render json: @alliances.map { |a|
      {
        id: a.id,
        partner_country: {
          id: a.partner_country.id,
          name: a.partner_country.name
        },
        alliance_type: {
          id: a.alliance_type.id,
          name: a.alliance_type.name,
          min_relations_level: a.alliance_type.min_relations_level
        }
      }
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /alliances.json
  def create
    country = Country.find(params[:country_id])
    partner_country = Country.find(params[:partner_country_id])
    alliance_type = AllianceType.find(params[:alliance_type_id])

    # Проверка на существующий союз
    existing_alliance = Alliance.find_by(
      country_id: country.id,
      partner_country_id: partner_country.id,
      alliance_type_id: alliance_type.id
    )

    if existing_alliance
      render json: { error: "Такой союз уже существует" }, status: :unprocessable_entity
      return
    end

    @alliance = Alliance.new(
      country: country,
      partner_country: partner_country,
      alliance_type: alliance_type
    )

    if @alliance.save
      render json: {
        id: @alliance.id,
        partner_country: {
          id: @alliance.partner_country.id,
          name: @alliance.partner_country.name
        },
        alliance_type: {
          id: @alliance.alliance_type.id,
          name: @alliance.alliance_type.name,
          min_relations_level: @alliance.alliance_type.min_relations_level
        }
      }, status: :created
    else
      render json: { error: @alliance.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # DELETE /alliances/:id.json
  def destroy
    @alliance.destroy
    render json: { success: true }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_alliance
    @alliance = Alliance.find(params[:id])
  end
end

