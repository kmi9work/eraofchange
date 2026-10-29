class ArmiesController < ApplicationController
  before_action :set_army, only: %i[show edit update destroy demote_army pay_for_army goto attack add_troop unlease]

  def goto
    @army.goto(params[:settlement_id])
  end

  def attack
    enemy = Army.active.find_by(id: params[:enemy_id])
    if enemy
      @army = @army.attack(params[:enemy_id], params[:voevoda_bonus])
      if @army
        render :show
      else
        render json: false
      end
    else
      render json: false
    end
  end
  
  def unlease
    @army.unlease
    render :show, status: :ok, location: @army
  end

  def index
    @armies = Army.active.order(:name)
    if params[:country_id].present?
      @armies = @armies.where(id: Army.for_country(Country.find_by(id: params[:country_id])).select(:id))
    elsif params[:foreign].to_s == '1'
      @armies = @armies.where(id: Army.foreign_to(current_country).select(:id))
    elsif params[:foreign].to_s == '0'
      @armies = @armies.where(id: Army.for_country(current_country).select(:id))
    end
  end

  def show
  end

  def pay_for_army
    @army.pay_for_army
  end

  def new
    @army = Army.new
  end

  def edit
  end

  def add_troop
    result = @army.add_troop(params[:troop_type_id])
    if result[:troop]
      render :show, status: :created, location: @army
    else
      # Отказ по лимиту состава (три отряда + одна пушка) отдаём ошибкой, чтобы
      # клиент показал причину, а не «что-то пошло не так».
      render json: { success: false, error: result[:msg] }, status: :unprocessable_entity
    end
  end

  # PATCH /armies/award_battle_victory.json?army_ids[]=1&army_ids[]=2
  #   &defeated_army_ids[]=3&defeated_army_ids[]=4
  #
  # Влияние Воеводе за сражение из клиента мастеров (era_native): бой там считается
  # на клиенте, поэтому `Army#attack` не вызывается и без этого действия Воевода
  # оставался без бонуса. Бонус (+4) — за КАЖДУЮ разбитую армию противника,
  # штраф (−1) — за каждую разбитую армию своего государства. Гарнизон города
  # армией на сервере не является и в списки не попадает.
  def award_battle_victory
    winner_ids = Array(params[:army_ids]).map(&:to_i).reject(&:zero?)
    defeated_ids = Array(params[:defeated_army_ids]).map(&:to_i).reject(&:zero?)
    awarded = Army.award_victory_influence(
      Army.active.where(id: winner_ids).to_a,
      Army.where(id: defeated_ids).to_a
    )
    render json: {
      success: true,
      bonus: Job::VOEVODA_BONUS,
      penalty: Job::VOEVODA_PENALTY,
      awarded: awarded
    }
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        format.html { redirect_to army_url(@army), notice: "Army was successfully created." }
        format.json { render :show, status: :created, location: @army }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @army.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @army.update(army_params)
        if params[:tainiy_bonus]
          # Бонус Тайного советника — совету текущего государства
          current_country&.council_players(Job::TAINIY)&.each do |player|
            player.modify_influence(Job::TAINIY_BONUS, "Бонус за разведку", @army) 
          end
        end
        format.html { redirect_to army_url(@army), notice: "Army was successfully updated." }
        format.json { render :show, status: :ok, location: @army }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { 
          error_messages = @army.errors.full_messages
          # Переводим стандартные сообщения об ошибках на русский
          error_messages = error_messages.map do |message|
            case message
            when "Name has already been taken"
              "Армия с таким названием уже существует"
            when "Name can't be blank"
              "Название армии не может быть пустым"
            when "Owner must exist"
              "Владелец армии должен быть указан"
            when "Settlement must exist"
              "Поселение должно быть указано"
            else
              message
            end
          end
          render json: { errors: error_messages }, status: :unprocessable_entity 
        }
      end
    end
  end

  def destroy
    @army.destroy

    respond_to do |format|
      format.html { redirect_to armies_url, notice: "Army was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_army
      @army = Army.active.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def army_params
      params.require(:army).permit(:name, :hidden, :settlement_id, :owner_id, :owner_type)
    end
end
