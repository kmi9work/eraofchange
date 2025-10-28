class CountriesController < ApplicationController
  before_action :set_country, only: %i[ show edit update destroy set_embargo change_relations capture edit_trade_thresholds show_trade_thresholds update_trade_thresholds add_relation_item show_current_trade_level join_peace calculate_trade_turnover improve_relations_via_trade]

  # GET /countries or /countries.json
  def index
    @countries = Country.all
    @countries = Country.where.not(id: Country::RUS) if params[:foreign].to_i == 1
    @countries = @countries.order(:name)
  end

  def foreign_countries
    @countries = Country.foreign_countries
    render 'index'
  end

  def set_embargo
    @country.set_embargo
    render json: { success: true, embargo: @country.embargo }
  end

  def join_peace
    @country.join_peace
  end

  def embargo
    @country.embargo(params[:arg])
  end

  def capture
    region = Region.find(params[:region_id])
    @country.capture(region, params[:how])
  end

  # GET /countries/1 or /countries/1.json
  def show
  end

  # GET /countries/new
  def new
    @country = Country.new
  end

  # GET /countries/1/edit
  def edit
  end

  def show_current_trade_level
    result = @country.show_current_trade_level
    render json: result
    rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def show_trade_thresholds
    result = @country.params&.dig("level_thresholds") || []
    render json: result
    rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_trade_thresholds
    new_thresholds = params[:thresholds]
    if new_thresholds.present?
      current_params = @country.params || {}
      current_params["level_thresholds"] = new_thresholds
      @country.params = current_params
      
      if @country.save
        render json: { success: true, thresholds: current_params["level_thresholds"] }
      else
        render json: { error: @country.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Thresholds parameter is required' }, status: :bad_request
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def show_trade_turnover
    result = Country.show_trade_turnover
    render json: result
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /countries or /countries.json
  def create
    @country = Country.new(country_params)

    respond_to do |format|

      if @country.save
        format.html { redirect_to country_url(@country), notice: "Country was successfully created." }
        format.json { render :show, status: :created, location: @country }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /countries/1 or /countries/1.json
  def update
    respond_to do |format|
      if @country.update(country_params)
        format.html { redirect_to country_url(@country), notice: "Country was successfully updated." }
        format.json { render :show, status: :ok, location: @country }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /countries/1 or /countries/1.json
  def destroy
    @country.destroy

    respond_to do |format|
      format.html { redirect_to countries_url, notice: "Country was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_relation_item
    value = params[:value].to_i
    comment = params[:comment].presence || "Ручная правка"
    @country.change_relations(value, @country, comment)
  end

  def improve_relations_via_trade
    result = @country.improve_relations_via_trade
    
    if result[:success]
      render json: { 
        success: true, 
        new_relations: result[:new_relations], 
        relation_points_left: result[:relation_points_left],
        message: 'Отношения улучшены через торговлю'
      }
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_country
      @country = Country.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def country_params
      params.require(:country).permit(:name, :params)
    end
end
