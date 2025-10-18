class Caravan < ApplicationRecord
  belongs_to :guild, optional: true
  belongs_to :country
  
  def self.register_caravan(params)
    trade_turnover = params[:purchase_cost].to_i + params[:sale_income].to_i 
    
    # Разделяем ресурсы из incoming (БЕЗ золота)
    incoming_resources = []
    
    params[:incoming]&.each do |item|
      if item[:count].present? && item[:count].to_i > 0
        incoming_resources << { 
          identificator: item[:identificator], 
          name: item[:name],
          count: item[:count].to_i 
        }
      end
    end
    
    # Разделяем ресурсы из outcoming (БЕЗ золота)
    outcoming_resources = []
    
    params[:outcoming]&.each do |item|
      if item[:count].present? && item[:count].to_i != 0
        outcoming_resources << { 
          identificator: item[:identificator],
          name: item[:name], 
          count: item[:count].to_i 
        }
      end
    end
    
    # Создаем караван
    caravan = Caravan.create!(
      country_id: params[:country_id],
      resources_from_pl: incoming_resources,
      resources_to_pl: outcoming_resources,
      trade_turnover: trade_turnover
    )
    
    { success: true, caravan: caravan }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  rescue => e
    { success: false, error: e.message }
  end
end
