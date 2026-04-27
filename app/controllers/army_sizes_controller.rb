class ArmySizesController < ApplicationController
  before_action :set_army_size, only: %i[ show edit update destroy ]

  # GET /army_sizes or /army_sizes.json
  def index
    @army_sizes = ArmySize.all
  end

  # GET /army_sizes/1 or /army_sizes/1.json
  def show
  end

  # GET /army_sizes/new
  def new
    @army_size = ArmySize.new
  end

  # GET /army_sizes/1/edit
  def edit
  end

  # POST /army_sizes or /army_sizes.json
  def create
    @army_size = ArmySize.new(army_size_params)

    respond_to do |format|
      if @army_size.save
        format.html { redirect_to army_size_url(@army_size), notice: "Army size was successfully created." }
        format.json { render :show, status: :created, location: @army_size }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @army_size.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /army_sizes/1 or /army_sizes/1.json
  def update
    respond_to do |format|
      if @army_size.update(army_size_params)
        format.html { redirect_to army_size_url(@army_size), notice: "Army size was successfully updated." }
        format.json { render :show, status: :ok, location: @army_size }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @army_size.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /army_sizes/1 or /army_sizes/1.json
  def destroy
    @army_size.destroy

    respond_to do |format|
      format.html { redirect_to army_sizes_url, notice: "Army size was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_army_size
      @army_size = ArmySize.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def army_size_params
      params.require(:army_size).permit(:level, :params)
    end
end
