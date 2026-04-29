class CountriesController < ApplicationController
  before_action :set_country, only: %i[ show edit update destroy set_embargo change_relations capture edit_trade_thresholds show_trade_thresholds update_trade_thresholds add_relation_item show_current_trade_level join_peace calculate_trade_turnover improve_relations_via_trade award_trade_level_points]

  # GET /countries or /countries.json
  def index
    @countries = Country.all
    @countries = Country.where.not(id: Country::RUS) if params[:foreign].to_i == 1
    @countries = Country.russian_countries if params[:russian].to_i == 1
    @countries = Country.vyatka_free_countries if params[:vyatka_free].to_i == 1
    @countries = Country.foreign_countries if params[:only_foreign].to_i == 1
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

  # GET /countries/trade_levels_and_thresholds?ids=1,2,3
  def trade_levels_and_thresholds
    ids_param = params[:ids]
    country_ids =
      case ids_param
      when String
        ids_param.split(',').map { |s| s.strip.to_i }.reject(&:zero?)
      when Array
        ids_param.map(&:to_i).reject(&:zero?)
      else
        []
      end

    countries = country_ids.present? ? Country.where(id: country_ids) : Country.none

    data = countries.map do |c|
      level = c.show_current_trade_level
      thresholds = c.params&.dig("level_thresholds") || []
      { country_id: c.id, level: level, thresholds: thresholds }
    end

    render json: { data: data }
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
    result = @country.change_relations(value, @country, comment, force: true)
    
    if result.is_a?(Hash) && result[:warning]
      render json: { success: true, warning: result[:warning] }
    else
      render json: { success: true }
    end
  end

  def improve_relations_via_trade
    # Используем force: true для мастера, чтобы разрешить улучшение, но получить предупреждение
    result = @country.improve_relations_via_trade(force: true)
    
    if result[:success]
      response = { 
        success: true, 
        new_relations: result[:new_relations], 
        relation_points_left: result[:relation_points_left],
        message: 'Отношения улучшены через торговлю'
      }
      response[:warning] = result[:warning] if result[:warning]
      render json: response
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  # Bulk update trade turnover for all countries except Vyatka
  def bulk_update_trade_turnover
    turnover_value = params[:turnover].to_i
    country_ids = params[:country_ids]
    
    if turnover_value < 0
      render json: { success: false, error: 'Turnover value must be non-negative' }, status: :bad_request
      return
    end
    
    if country_ids.nil? || !country_ids.is_a?(Array)
      # Default: update all countries except Vyatka (id: 9)
      country_ids = Country.foreign_countries.pluck(:id)
    end
    
    updated_countries = []
    country_ids.each do |country_id|
      country = Country.find(country_id)
      # Skip Vyatka
      next if country.id == Country::VYATKA
      
      # Store manual turnover adjustment in params
      current_params = country.params || {}
      current_params['manual_trade_turnover'] = turnover_value
      country.params = current_params
      country.save!
      
      updated_countries.push({
        country_id: country.id,
        country_name: country.name,
        short_name: country.short_name || country.name,
        manual_turnover: turnover_value
      })
    end
    
    render json: {
      success: true,
      message: "Trade turnover updated for #{updated_countries.count} countries",
      countries: updated_countries
    }
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  # Bulk award trade level points for all countries except Vyatka
  def bulk_award_trade_level_points
    country_ids = params[:country_ids]
    
    if country_ids.nil? || !country_ids.is_a?(Array)
      # Default: all countries except Vyatka (id: 9)
      country_ids = Country.foreign_countries.pluck(:id)
    end
    
    awarded_countries = []
    country_ids.each do |country_id|
      country = Country.find(country_id)
      # Skip Vyatka
      next if country.id == Country::VYATKA
      
      # Calculate current turnover and award points
      current_trade_turnover = country.calculate_trade_turnover[:trade_turnover] || 0
      previous_turnover = country.params&.dig('last_trade_turnover')
      
      result = country.check_and_award_trade_level_points(previous_trade_turnover: previous_turnover)
      
      if result[:success] || result[:current_level]
        awarded_countries.push({
          country_id: country.id,
          country_name: country.name,
          short_name: country.short_name || country.name,
          current_level: result[:current_level] || 0,
          points_awarded: result[:points_awarded] || 0,
          message: result[:message] || 'No points awarded'
        })
      end
    end
    
    render json: {
      success: true,
      message: "Trade levels processed for #{awarded_countries.count} countries",
      countries: awarded_countries
    }
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def award_trade_level_points
    previous_turnover = params[:previous_trade_turnover]
    result = @country.check_and_award_trade_level_points(
      previous_trade_turnover: previous_turnover&.to_i
    )
    
    if result[:success]
      render json: result
    else
      render json: result, status: :ok
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  # Bulk update trade thresholds for all countries except Vyatka
  def bulk_update_trade_thresholds
    new_thresholds = params[:thresholds]
    
    if new_thresholds.present? && new_thresholds.is_a?(Array)
      country_ids = params[:country_ids]
      
      if country_ids.nil? || !country_ids.is_a?(Array)
        # Default: all countries except Vyatka (id: 9)
        country_ids = Country.foreign_countries.pluck(:id)
      end
      
      updated_countries = []
      country_ids.each do |country_id|
        country = Country.find(country_id)
        # Skip Vyatka
        next if country.id == Country::VYATKA
        
        # Update thresholds
        current_params = country.params || {}
        current_params["level_thresholds"] = new_thresholds
        country.params = current_params
        
        if country.save
          updated_countries.push({
            country_id: country.id,
            country_name: country.name,
            short_name: country.short_name || country.name
          })
        end
      end
      
      render json: {
        success: true,
        message: "Trade thresholds updated for #{updated_countries.count} countries",
        countries: updated_countries
      }
    else
      render json: { error: 'Thresholds parameter is required and must be an array' }, status: :bad_request
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
