class IdeologistTechnologiesController < ApplicationController
  before_action :set_ideologist_technology, only: %i[ show edit update destroy ]

  # GET /ideologist_technologies or /ideologist_technologies.json
  def index
    @ideologist_technologies = IdeologistTechnology.all
  end

  # GET /ideologist_technologies/1 or /ideologist_technologies/1.json
  def show
  end

  # GET /ideologist_technologies/new
  def new
    @ideologist_technology = IdeologistTechnology.new
  end

  # GET /ideologist_technologies/1/edit
  def edit
  end

  # POST /ideologist_technologies or /ideologist_technologies.json
  def create
    @ideologist_technology = IdeologistTechnology.new(ideologist_technology_params)

    respond_to do |format|
      if @ideologist_technology.save
        format.html { redirect_to ideologist_technology_url(@ideologist_technology), notice: "Ideologist technology was successfully created." }
        format.json { render :show, status: :created, location: @ideologist_technology }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ideologist_technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ideologist_technologies/1 or /ideologist_technologies/1.json
  def update
    respond_to do |format|
      if @ideologist_technology.update(ideologist_technology_params)
        format.html { redirect_to ideologist_technology_url(@ideologist_technology), notice: "Ideologist technology was successfully updated." }
        format.json { render :show, status: :ok, location: @ideologist_technology }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ideologist_technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ideologist_technologies/1 or /ideologist_technologies/1.json
  def destroy
    @ideologist_technology.destroy

    respond_to do |format|
      format.html { redirect_to ideologist_technologies_url, notice: "Ideologist technology was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ideologist_technology
      @ideologist_technology = IdeologistTechnology.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ideologist_technology_params
      params.require(:ideologist_technology).permit(:title, :requirements, :params, :ideologist_type_id)
    end
end
