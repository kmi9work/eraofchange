class Caravan < ApplicationRecord
  belongs_to :guild, optional: true
  belongs_to :country

  def self.register_caravan(params)
    country = Country.find(params[:country_id])
  
    # Получаем предыдущий уровень ДО создания каравана
    previous_level_info = country.show_current_trade_level
    previous_level = previous_level_info[:current_level]  # ✅ Исправлено: это уже число
    previous_level ||= 1

    # Создаем караван и проверяем результат
    result = create_caravan(params)
    return result unless result[:success]  # ✅ Возвращаем ошибку если не удалось создать
    
    caravan = result[:caravan]

    # ✅ Перезагружаем country для получения обновленных данных
    country.reload
    
    # Получаем новый уровень ПОСЛЕ создания каравана
    new_level_info = country.show_current_trade_level
    new_level = new_level_info[:current_level]  # ✅ Исправлено: это уже число
    new_level ||= 1

    # Вычисляем разницу и обновляем отношения
    if new_level > previous_level
      diff = new_level - previous_level
      # ✅ Исправлено: безопасная инициализация
      current_params = country.params || {}
      current_params["relation_points"] = (current_params["relation_points"] || 0) + diff
      country.params = current_params
      country.save
    end
    
    # ✅ Исправлено: возвращаем результат
    { success: true, caravan: caravan, level_increased: new_level > previous_level }
    
  rescue ActiveRecord::RecordNotFound => e
    { success: false, error: "Country not found: #{e.message}" }
  rescue => e
    { success: false, error: e.message }
  end
  

  # ✅ Исправлено: правильный способ для class methods
  class << self
    private
    
    def create_caravan(params)
      caravan = Caravan.create!(
        country_id:        params[:country_id],
        resources_from_pl: params[:incoming],
        resources_to_pl:   params[:outcoming],
        gold_from_pl:      params[:purchase_cost],
        gold_to_pl:        params[:sale_income] 
      )
      
      { success: true, caravan: caravan }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, error: e.message }
    rescue => e
      { success: false, error: e.message }
    end
  end


end
