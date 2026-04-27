class AllianceTypesController < ApplicationController
  before_action :set_alliance_type, only: [:show, :update, :destroy]

  # GET /alliance_types.json
  def index
    @alliance_types = AllianceType.all.order(:min_relations_level, :name)
    render json: @alliance_types.map { |at|
      {
        id: at.id,
        name: at.name,
        min_relations_level: at.min_relations_level
      }
    }
  end

  # GET /alliance_types/:id.json
  def show
    render json: {
      id: @alliance_type.id,
      name: @alliance_type.name,
      min_relations_level: @alliance_type.min_relations_level
    }
  end

  # POST /alliance_types.json
  def create
    @alliance_type = AllianceType.new(alliance_type_params)

    if @alliance_type.save
      render json: {
        id: @alliance_type.id,
        name: @alliance_type.name,
        min_relations_level: @alliance_type.min_relations_level
      }, status: :created
    else
      render json: { error: @alliance_type.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /alliance_types/:id.json
  def update
    if @alliance_type.update(alliance_type_params)
      render json: {
        id: @alliance_type.id,
        name: @alliance_type.name,
        min_relations_level: @alliance_type.min_relations_level
      }, status: :ok
    else
      render json: { error: @alliance_type.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # DELETE /alliance_types/:id.json
  def destroy
    @alliance_type.destroy
    render json: { success: true }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_alliance_type
    @alliance_type = AllianceType.find(params[:id])
  end

  def alliance_type_params
    params.require(:alliance_type).permit(:name, :min_relations_level)
  end
end

