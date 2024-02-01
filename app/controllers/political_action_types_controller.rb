class PoliticalActionTypesController < ApplicationController
  before_action :set_political_action_type, only: %i[ show edit update destroy ]

  # GET /political_action_types or /political_action_types.json
  def index
    @political_action_types = PoliticalActionType.all
  end

  # GET /political_action_types/1 or /political_action_types/1.json
  def show
  end

  # GET /political_action_types/new
  def new
    @political_action_type = PoliticalActionType.new
  end

  # GET /political_action_types/1/edit
  def edit
  end

  # POST /political_action_types or /political_action_types.json
  def create
    @political_action_type = PoliticalActionType.new(political_action_type_params)

    respond_to do |format|
      if @political_action_type.save
        format.html { redirect_to political_action_type_url(@political_action_type), notice: "Political action type was successfully created." }
        format.json { render :show, status: :created, location: @political_action_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @political_action_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /political_action_types/1 or /political_action_types/1.json
  def update
    respond_to do |format|
      if @political_action_type.update(political_action_type_params)
        format.html { redirect_to political_action_type_url(@political_action_type), notice: "Political action type was successfully updated." }
        format.json { render :show, status: :ok, location: @political_action_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @political_action_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /political_action_types/1 or /political_action_types/1.json
  def destroy
    @political_action_type.destroy

    respond_to do |format|
      format.html { redirect_to political_action_types_url, notice: "Political action type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_political_action_type
      @political_action_type = PoliticalActionType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def political_action_type_params
      params.require(:political_action_type).permit(:title, :action, :params)
    end
end
