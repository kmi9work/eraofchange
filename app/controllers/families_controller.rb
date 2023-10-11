class FamiliesController < ApplicationController
  before_action :set_family, only: %i[ show edit update destroy ]

  # GET /families or /families.json
  def index
    @families = Family.all
  end

  # GET /families/1 or /families/1.json
  def show
  end

  # GET /families/new
  def new
    @family = Family.new
  end

  # GET /families/1/edit
  def edit
  end

  def create
    @family = Family.new(family_params)
  end

  # PATCH/PUT /families/1 or /families/1.json
  def update
  end

  # DELETE /families/1 or /families/1.json
  def destroy
    @family.destroy
    redirect_to ("/families/")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_family
      @family = Family.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def family_params
      # params.fetch(:family, {})
      # permit(:name)
      params.require(:family).permit(:name)
    end


end
