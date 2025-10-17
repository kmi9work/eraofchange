class Caravan < ApplicationRecord
  belongs_to :guild, optional: true
  belongs_to :country
  
  def self.register_caravan(params)
    # Разделяем ресурсы и золото из incoming (что игрок отправляет)
    incoming_resources = []
    gold_player_paid = 0  # Сколько золота игрок положил
    
    params[:incoming]&.each do |item|
      if item[:identificator] == 'gold'
        gold_player_paid = item[:count].to_i
      elsif item[:count].present? && item[:count].to_i > 0
        incoming_resources << { 
          identificator: item[:identificator], 
          name: item[:name],
          count: item[:count].to_i 
        }
      end
    end
    
    # Разделяем ресурсы и золото из outcoming (результат торговли)
    outcoming_resources = []
    gold_result = 0  # Результат торговли (может быть отрицательным)
    
    params[:outcoming]&.each do |item|
      if item[:identificator] == 'gold' || item[:name] == 'Золото' || item[:name]&.downcase&.include?('золото')
        gold_result = item[:count].to_i
      elsif item[:count].present? && item[:count].to_i != 0
        outcoming_resources << { 
          identificator: item[:identificator],
          name: item[:name], 
          count: item[:count].to_i 
        }
      end
    end
    
    # ЛОГИКА ОБРАБОТКИ ЗОЛОТА:
    # gold_result < 0: игрок должен ЗАПЛАТИТЬ (покупает)
    # gold_result > 0: игрок ПОЛУЧАЕТ (продает)
    # gold_result = 0: обмен без денег
    
    incoming_gold = 0
    outcoming_gold = 0
    
    if gold_result < 0
      # Игрок покупает (должен заплатить)
      payment_needed = gold_result.abs
      incoming_gold = gold_player_paid  # Сколько игрок положил
      
      # Если игрок положил больше, чем нужно - будет сдача
      if gold_player_paid > payment_needed
        outcoming_gold = gold_player_paid - payment_needed
      else
        outcoming_gold = 0
      end
    elsif gold_result > 0
      # Игрок продает (получает деньги)
      incoming_gold = gold_player_paid  # Может быть 0
      outcoming_gold = gold_result
    else
      # Обмен без денег
      incoming_gold = gold_player_paid
      outcoming_gold = 0
    end
    
    # Создаем караван
    caravan = Caravan.create!(
      country_id: params[:country_id],
      incoming_resources: incoming_resources,
      incoming_gold: incoming_gold,
      outcoming_resources: outcoming_resources,
      outcoming_gold: outcoming_gold
    )
    
    { success: true, caravan: caravan }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  rescue => e
    { success: false, error: e.message }
  end
end
