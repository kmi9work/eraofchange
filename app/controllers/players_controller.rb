class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy add_influence show_players_resources receive_from_masters exchange_resources show_players_plants buy_and_sell_res]

  def show_players_resources
     render json: @player.resources || []
  end

  def receive_from_masters
    Rails.logger.info "=== receive_from_masters called ==="
    Rails.logger.info "Player ID: #{@player.id}"
    Rails.logger.info "Params: #{params.inspect}"
    
    resources = params[:hashed_resources] || params[:resources] || []
    Rails.logger.info "Resources to add: #{resources.inspect}"
    
    @player.add_resources_to_recipient(@player, resources)
    
    if @player.save
      Rails.logger.info "Resources saved successfully"
      render json: { success: true, resources: @player.resources }
    else
      Rails.logger.error "Failed to save: #{@player.errors.full_messages}"
      render json: { success: false, error: @player.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def show_players_plants
    render json: @player.plants || []
  end

  def produce_at_plant
    @player.produce(params[:plant_id], params[:hashed_resources])
  end

  def exchange_resources
    result = @player.exchange_resources(
      params[:request][:with_whom], 
      params[:request][:hashed_resources]
    )
    render json: { success: true, result: result }
    rescue => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def buy_and_sell_res
    Rails.logger.info "=== BUY_AND_SELL_RES ==="
    Rails.logger.info "res_pl_sells: #{params[:res_pl_sells].inspect}"
    Rails.logger.info "res_pl_buys: #{params[:res_pl_buys].inspect}"
    
    result = @player.buy_and_sell_res(
      params[:res_pl_sells] || [],
      params[:res_pl_buys] || []
    )
    render json: result
  rescue => e
    Rails.logger.error "Error in buy_and_sell_res: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /players or /players.json
  def index
    scope = Player.order(:id)
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
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to player_url(@player), notice: "Player was successfully updated." }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
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

  def add_influence
    value = params[:value].to_i
    comment = params[:comment].presence || "Ручная правка"
    @player.modify_influence(value, comment, nil)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:name, :family_id, :guild_id, :player_type_id, :job_ids => [], :credit_ids => [], :political_action_ids => [], :plant_ids => [], :params => {})
    end
end
