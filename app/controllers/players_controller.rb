class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]

  # GET /players or /players.json
  def index
    scope = Player.all
    if params[:player_type_id].present?
      scope = scope.where(player_type_id: params[:player_type_id])
    end
    @players = scope
  end

  # GET /players/1 or /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  def create
    @player = Player.new(player_params)
     if @player.save
      redirect_to player_url(@player)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      redirect_to player_url(@player)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to ("/players/")
  end

  def add_army
    army_size_id = params[:army_size_id]
    region_id = params[:region_id]
    @player.add_army(army_size_id, region_id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:name, :family_id, :guild_id, :player_type_id, :job_id, :credit_ids => [], :political_action_ids => [], :plant_ids => [])
    end
end
