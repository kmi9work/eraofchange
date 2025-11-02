class PoliticalActionsController < ApplicationController
  before_action :set_political_action, only: %i[ show edit update destroy ]

  # GET /political_actions or /political_actions.json
  def index
    @political_actions = PoliticalAction.includes(:job, :political_action_type, :player)
  end

  # GET /political_actions/1 or /political_actions/1.json
  def show
  end

  # GET /political_actions/new
  def new
    @political_action = PoliticalAction.new
  end

  # GET /political_actions/1/edit
  def edit
  end

  # POST /political_actions or /political_actions.json
  def create
    @political_action = PoliticalAction.new(political_action_params)
    @political_action.year = GameParameter.current_year
    @political_action.player_id = Job.find_by_id(political_action_params[:job_id])&.players&.first&.id

    # Проверяем, требует ли метод success (старая система) или выполняется напрямую (плагин)
    action_method = @political_action.political_action_type&.action
    uses_plugin_system = action_method && @political_action.respond_to?(action_method) && 
                         !action_requires_success?(action_method)

    respond_to do |format|
      if @political_action.save
        # Выполняем действие
        begin
          if uses_plugin_system
            # Новая система плагина - выполняем метод напрямую
            Rails.logger.info "[PoliticalAction] Executing plugin method: #{action_method}"
            result = @political_action.send(action_method)
            Rails.logger.info "[PoliticalAction] Plugin method executed successfully: #{result.inspect}"
          else
            # Старая система - используем execute с проверкой success
            Rails.logger.info "[PoliticalAction] Executing core method: #{action_method}"
            @political_action.execute
          end
        rescue => e
          Rails.logger.error "[PoliticalAction] Error executing #{action_method}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          format.html { redirect_to political_actions_url, alert: "Ошибка выполнения действия: #{e.message}" }
          format.json { render json: {error: e.message}, status: :unprocessable_entity }
          return
        end
        
        format.html { redirect_to political_action_url(@political_action), notice: "Political action was successfully created." }
        format.json { render :show, status: :created, location: @political_action }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @political_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /political_actions/1 or /political_actions/1.json
  def update
    respond_to do |format|
      if @political_action.update(political_action_params)
        format.html { redirect_to political_action_url(@political_action), notice: "Political action was successfully updated." }
        format.json { render :show, status: :ok, location: @political_action }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @political_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /political_actions/1 or /political_actions/1.json
  def destroy
    @political_action.destroy

    respond_to do |format|
      format.html { redirect_to political_actions_url, notice: "Political action was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_political_action
      @political_action = PoliticalAction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def political_action_params
      params.require(:political_action).permit(:year, :success, :player_id, :job_id, :political_action_type_id, params: {})
    end

    # Проверяет, использует ли метод старую систему с success
    def action_requires_success?(action_method)
      # Методы ядра игры, которые проверяют success
      core_actions_with_success = %w[
        sedition charity sabotage contraband open_gate new_fisheries people_support
        ceremonial defective_coin call_a_meeting send_embassy take_bribe equip_caravan
        conduct_audit peculation disperse_bribery implement_sabotage name_of_grand_prince
        recruiting drain_the_swamps contract_to_cousin improving_the_city sermon
        root_out_heresies call_for_unity counterintelligence fabricate_a_denunciation 
        favoritism dev_the_economy confused_mine patronage_of_infidel
      ]
      
      core_actions_with_success.include?(action_method.to_s)
    end
end
