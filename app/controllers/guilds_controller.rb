class GuildsController < ApplicationController
  before_action :set_guild, only: %i[ show edit update destroy ]

  def index
    @guilds = Guild.all
  end

  def show
  end

  def new
    @guild = Guild.new
    @merch = Merchant.where(guild_id: nil)
  end

  def edit
    @merch = Merchant.where(guild_id: [nil, @guild.id])
  end

  def create
    @guild = Guild.new(guild_params)
    if @guild.save
      redirect_to guild_url(@guild), notice: "Гильдия успешно создана."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @guild.update(guild_params)
      redirect_to guild_url(@guild), notice: "Запись успешно обновлена."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @guild.destroy

    redirect_to guilds_url, notice: "Запись успешно удалена."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guild
      @guild = Guild.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def guild_params
      params.require(:guild).permit(:name, :merchant_ids => [], :plant_ids => [])
    end
end
