class PoliticalActionsController < ApplicationController
  before_action :set_political_action, only: %i[ show edit update destroy ]

  # GET /political_actions or /political_actions.json
  def index
    @political_actions = PoliticalAction.all
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

    respond_to do |format|
      if @political_action.save
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
      params.require(:political_action).permit(:year, :success, :params, :political_action_type_id, :player_id)
    end
end
