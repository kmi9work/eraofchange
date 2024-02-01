class FossilTypesController < ApplicationController
  before_action :set_fossil_type, only: %i[ show edit update destroy ]

  # GET /fossil_types or /fossil_types.json
  def index
    @fossil_types = FossilType.all
  end

  # GET /fossil_types/1 or /fossil_types/1.json
  def show
  end

  # GET /fossil_types/new
  def new
    @fossil_type = FossilType.new
  end

  # GET /fossil_types/1/edit
  def edit
  end

  # POST /fossil_types or /fossil_types.json
  def create
    @fossil_type = FossilType.new(fossil_type_params)

    respond_to do |format|
      if @fossil_type.save
        format.html { redirect_to fossil_type_url(@fossil_type), notice: "Fossil type was successfully created." }
        format.json { render :show, status: :created, location: @fossil_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fossil_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fossil_types/1 or /fossil_types/1.json
  def update
    respond_to do |format|
      if @fossil_type.update(fossil_type_params)
        format.html { redirect_to fossil_type_url(@fossil_type), notice: "Fossil type was successfully updated." }
        format.json { render :show, status: :ok, location: @fossil_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fossil_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fossil_types/1 or /fossil_types/1.json
  def destroy
    @fossil_type.destroy

    respond_to do |format|
      format.html { redirect_to fossil_types_url, notice: "Fossil type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fossil_type
      @fossil_type = FossilType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fossil_type_params
      params.require(:fossil_type).permit(:title)
    end
end
