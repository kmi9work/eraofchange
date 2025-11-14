class PlantsController < ApplicationController
  before_action :set_plant, only: %i[ show edit update destroy name_of_plant upgrade has_produced ]

  def name_of_plant
    @plant.name_of_plant
  end

  def has_produced
    @plant.has_produced!
  end

  def index
    @plants = Plant.all
  end

  def show
  end

  def new
    @plant = Plant.new
  end

  def edit
  end

  def create
    Rails.logger.info "=== PLANT CREATE DEBUG ==="
    Rails.logger.info "Raw params: #{params.inspect}"
    Rails.logger.info "Plant params: #{plant_params.inspect}"
    
    @plant = Plant.new(plant_params)
    
    Rails.logger.info "Plant before economic_subject: #{@plant.inspect}"
    
    # Устанавливаем economic_subject после создания объекта
    # Поддерживаем оба формата: params[:plant][:economic_subject] и params[:economic_subject]
    economic_subject_value = params[:plant]&.dig(:economic_subject) || params[:economic_subject]
    write_economic_subject if economic_subject_value.present?
    
    Rails.logger.info "Plant before save: #{@plant.inspect}"
    
    respond_to do |format|
      if @plant.save
        Rails.logger.info "Plant after save - ID: #{@plant.id}"
        Rails.logger.info "Plant after save: #{@plant.inspect}"
        
        format.html { redirect_to plant_url(@plant), notice: "Plant was successfully created." }
        format.json { render json: @plant, status: :created, location: @plant }
      else
        Rails.logger.error "Plant save failed: #{@plant.errors.inspect}"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @plant.assign_attributes(plant_params)
    # Поддерживаем оба формата: params[:plant][:economic_subject] и params[:economic_subject]
    economic_subject_value = params[:plant]&.dig(:economic_subject) || params[:economic_subject]
    write_economic_subject if economic_subject_value.present?
    if @plant.save
      redirect_to plant_url(@plant)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant.destroy

    respond_to do |format|
      format.html { redirect_to(plants_path) }
      format.json { head :no_content }
    end
  end

  # POST /plants/:id/print_barcode
  def print_barcode
    @plant = Plant.find(params[:id])
    
    begin
      # Здесь будет логика печати штрихкода
      # Пока что просто возвращаем успех
      formatted_id = @plant.id.to_s.rjust(9, '0')
      
      # Логируем попытку печати
      Rails.logger.info "Печать штрихкода для предприятия ID: #{formatted_id}"
      
      render json: { 
        success: true, 
        message: "Штрихкод успешно напечатан",
        plant_id: @plant.id,
        formatted_id: formatted_id
      }
    rescue => e
      Rails.logger.error "Ошибка печати штрихкода: #{e.message}"
      render json: { 
        success: false, 
        error: e.message 
      }, status: :unprocessable_entity
    end
  end

  def upgrade
    begin
      Rails.logger.info "=== UPGRADE DEBUG ==="
      Rails.logger.info "Plant ID: #{@plant.id}"
      Rails.logger.info "Current plant_level_id: #{@plant.plant_level_id}"
      Rails.logger.info "Current level: #{@plant.plant_level&.level}"
      
      result = @plant.upgrade!
      
      Rails.logger.info "Upgrade result: #{result.inspect}"
      
      if result[:plant_level].present?
        respond_to do |format|
          format.html { redirect_back(fallback_location: plant_path(@plant), notice: result[:msg]) }
          format.json { render json: { success: true, msg: result[:msg], plant: @plant }, status: :ok }
        end
      else
        Rails.logger.warn "Upgrade failed: #{result[:msg]}"
        respond_to do |format|
          format.html { redirect_back(fallback_location: plant_path(@plant), alert: result[:msg]) }
          format.json { render json: { success: false, error: result[:msg] }, status: :unprocessable_entity }
        end
      end
    rescue => e
      Rails.logger.error "Ошибка улучшения предприятия: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      respond_to do |format|
        format.html { redirect_back(fallback_location: plant_path(@plant), alert: "Ошибка: #{e.message}") }
        format.json { render json: { success: false, error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant
      @plant = Plant.find(params[:id])
    end

      # Only allow a list of trusted parameters through.
    def plant_params
      # Поддерживаем оба формата: обёрнутые в :plant и прямые параметры
      if params[:plant].present?
        params.require(:plant).permit(:comments, :plant_level_id, :plant_place_id, :credit_id)
      else
        params.permit(:comments, :plant_level_id, :plant_place_id, :credit_id)
      end
    end

    def write_economic_subject
      # Поддерживаем оба формата: params[:plant][:economic_subject] и params[:economic_subject]
      economic_subject_value = params[:plant]&.dig(:economic_subject) || params[:economic_subject]
      return unless economic_subject_value.present?
      
      es_id, es_type = economic_subject_value.split('_')
      
      # Находим объект economic_subject
      if es_type == 'Guild'
        @plant.economic_subject = Guild.find(es_id.to_i)
        Rails.logger.info "Set economic_subject to Guild ID: #{es_id}"
      elsif es_type == 'Player'
        @plant.economic_subject = Player.find(es_id.to_i)
        Rails.logger.info "Set economic_subject to Player ID: #{es_id}"
      end
    end
end




  
