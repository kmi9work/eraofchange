class IdeologistTypesController < ApplicationController
  before_action :set_ideologist_type, only: %i[ show edit update destroy ]

  # GET /ideologist_types or /ideologist_types.json
  def index
    @ideologist_types = IdeologistType.all
  end

  # GET /ideologist_types/1 or /ideologist_types/1.json
  def show
  end

  # GET /ideologist_types/new
  def new
    @ideologist_type = IdeologistType.new
  end

  # GET /ideologist_types/1/edit
  def edit
  end

  # POST /ideologist_types or /ideologist_types.json
  def create
    @ideologist_type = IdeologistType.new(ideologist_type_params)

    respond_to do |format|
      if @ideologist_type.save
        format.html { redirect_to ideologist_type_url(@ideologist_type), notice: "Ideologist type was successfully created." }
        format.json { render :show, status: :created, location: @ideologist_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ideologist_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ideologist_types/1 or /ideologist_types/1.json
  def update
    respond_to do |format|
      if @ideologist_type.update(ideologist_type_params)
        format.html { redirect_to ideologist_type_url(@ideologist_type), notice: "Ideologist type was successfully updated." }
        format.json { render :show, status: :ok, location: @ideologist_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ideologist_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ideologist_types/1 or /ideologist_types/1.json
  def destroy
    @ideologist_type.destroy

    respond_to do |format|
      format.html { redirect_to ideologist_types_url, notice: "Ideologist type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ideologist_type
      @ideologist_type = IdeologistType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ideologist_type_params
      params.require(:ideologist_type).permit(:name)
    end
end
