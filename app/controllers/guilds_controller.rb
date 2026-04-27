class GuildsController < ApplicationController
  before_action :set_guild, only: %i[ show edit update destroy assign_players ]

  def index
    @guilds = Guild.all
  end

  def show
  end

  def new
    @guild = Guild.new
    @ownerless_plants = Plant.where(economic_subject_id: nil)
    @guildless_players = Player.where(guild_id: nil)
  end

  def edit
    @ownerless_plants = Plant.where(economic_subject_id: [nil, @guild.id])
    @guildless_players = Player.where(guild_id: [nil, @guild.id])
  end

  def create
    @guild = Guild.new(guild_params.except(:player_ids))
    if @guild.save
      assign_players_to_guild(@guild, guild_params[:player_ids]) if guild_params[:player_ids]
      respond_to do |format|
        format.html { redirect_to guild_url(@guild), notice: "Гильдия успешно создана." }
        format.json { render :show, status: :created, location: @guild }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @guild.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @guild.update(guild_params.except(:player_ids))
      assign_players_to_guild(@guild, guild_params[:player_ids]) if guild_params[:player_ids]
      respond_to do |format|
        format.html { redirect_to guild_url(@guild), notice: "Запись успешно обновлена." }
        format.json { render :show, status: :ok, location: @guild }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @guild.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @guild.destroy
    respond_to do |format|
      format.html { redirect_to guilds_url, notice: "Запись успешно удалена." }
      format.json { render json: { success: true } }
    end
  end

  def list
    @guilds = Guild.all
    render :index
  end

  # PATCH /guilds/:id/assign_players
  def assign_players
    player_ids = params[:player_ids] || []
    assign_players_to_guild(@guild, player_ids)
    render :show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guild
      @guild = Guild.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def guild_params
      params.require(:guild).permit(:name, :player_ids => [], :plant_ids => [])
    end

    def assign_players_to_guild(guild, player_ids)
      ids = Array(player_ids).map(&:to_i).uniq
      # Отвязываем игроков, которых больше нет в списке
      Player.where(guild_id: guild.id).where.not(id: ids).update_all(guild_id: nil)
      # Привязываем переданных игроков
      Player.where(id: ids).update_all(guild_id: guild.id)
    end
end
