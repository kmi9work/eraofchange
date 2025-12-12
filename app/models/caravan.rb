class Caravan < ApplicationRecord
  belongs_to :guild, optional: true
  belongs_to :country

   MAX_TRADE_POINTS = 3
   GRAND_PRINCE_SHARE = 0.10
  #Подсчет, сколько надо досыпать золота Великому Князю
  def self.count_caravan_revenue
    prev_year = GameParameter.current_year - 1
    return 0 if Caravan.all.empty? or prev_year < 0
    (Caravan.where(year: prev_year).sum(:gold_import).to_i * GRAND_PRINCE_SHARE).floor
  end

  # Публичный метод для проверки ограбления каравана
  def self.check_robbery(guild_id)
    check_caravan_robbery(guild_id)
  end
  
  # Публичный метод для проверки ограбления с принятием решения
  def self.check_robbery_with_decide(guild_id)
    check_caravan_robbery_with_decide(guild_id)
  end

  def self.register_caravan(params)
    via_vyatka = params[:via_vyatka] == true || params[:via_vyatka] == 'true' || params[:via_vyatka] == 1
    return send_caravan_via_vyatka(params) if via_vyatka

    is_protected = params[:is_protected] == true || params[:is_protected] == 'true' || params[:is_protected] == 1

    country = Country.find(params[:country_id])
    current_year = GameParameter.current_year

    if !is_protected
      robbery_check = check_robbery_with_decide(params[:guild_id])
      if robbery_check[:robbed]
        current_year = GameParameter.current_year
        GameParameter.increment_arrived_count(current_year)
        GameParameter.increment_robbed_count(current_year)
        return { success: false, robbed: true, error: "Караван был ограблен" }
      end
    end

    # Создаем караван и проверяем результат
    result = create_caravan(params)
    
    # Инкрементируем счетчик пришедших караванов (только если караван создан)
    if result[:success]
      GameParameter.increment_arrived_count(current_year)
    end
    
    return result unless result[:success] 
    
    caravan = result[:caravan]

    country.reload

    { success: true, caravan: caravan, level_increased: false}
    
  rescue ActiveRecord::RecordNotFound => e
    { success: false, error: "Country not found: #{e.message}" }
  rescue => e
    { success: false, error: e.message }
  end
  
  class << self
    private

    def send_caravan_via_vyatka(params)
      result = create_caravan(params)

      if result[:success]
        GameParameter.increment_arrived_count(GameParameter.current_year)
      end
      
      return { success: true, caravan: result[:caravan], level_increased: false, via_vyatka: true } if result[:success]
      return result
    end
      
    def check_caravan_robbery(guild_id)
      return { robbed: false } if guild_id.nil?
      
      # Получаем текущий год
      current_year = GameParameter.current_year
      
      # Получаем защищенные гильдии в текущем году
      protected_guilds = GameParameter.get_protected_guilds_for_year(current_year)
      
      # Если гильдия защищена, ограбление не происходит
      return { robbed: false, probability: 0 } if protected_guilds.include?(guild_id.to_i)
      
      # Скользящая вероятность: P = k / (N - n)
      # где:
      # n - количество караванов, которые уже пришли
      # k - количество караванов, которые еще нужно ограбить
      # N - общее количество караванов, которые могут быть ограблены
      # K - количество караванов, которые должны быть ограблены
      
      # Получаем количество ограблений, которые ПЛАНИРУЕТСЯ совершить в этом году
      planned_robberies = GameParameter.get_robbery_count_for_year(current_year).to_i
      
      # Если не планируется ни одного ограбления
      return { robbed: false, probability: 0 } if planned_robberies == 0
      
      # Получаем количество караванов в гильдии
      caravans_per_guild = GameParameter.get_caravans_per_guild.to_f
      
      # Получаем общее количество гильдий
      total_guilds = Guild.count.to_f
      
      # Количество защищенных гильдий
      protected_count = protected_guilds.count.to_f
      
      # total_caravans - общее количество караванов, которые могут быть ограблены
      total_caravans = (total_guilds - protected_count) * caravans_per_guild
      
      # Проверяем деление на ноль
      return { robbed: false, probability: 0 } if total_caravans <= 0
      
      # arrived_count - количество караванов, которые уже пришли (только незащищенные гильдии)
      arrived_count = GameParameter.get_arrived_count_for_year(current_year)
      
      # remaining_robberies - количество караванов, которые еще нужно ограбить
      remaining_robberies = planned_robberies - GameParameter.get_robbed_count_for_year(current_year)
      
      # Проверяем, не превысили ли лимит ограблений
      return { robbed: false, probability: 0 } if remaining_robberies <= 0
      
      # Проверяем, не кончились ли караваны
      return { robbed: false, probability: 0 } if arrived_count >= total_caravans
      
      # Вычисляем скользящую вероятность P = k / (N - n)
      denominator = total_caravans - arrived_count
      probability = denominator > 0 ? remaining_robberies.to_f / denominator : 0
      
      # Гарантируем, что вероятность не превышает 1
      probability = [probability, 1.0].min
      
      # Отладочная информация
      Rails.logger.debug("Caravan robbery check: planned=#{planned_robberies}, arrived=#{arrived_count}, robbed=#{GameParameter.get_robbed_count_for_year(current_year)}, remaining=#{remaining_robberies}, total_caravans=#{total_caravans}, probability=#{probability}")
      
      { robbed: false, probability: probability, arrived: arrived_count, remaining: remaining_robberies }
    end
    
    # Версия check_caravan_robbery, которая принимает решение об ограблении
    def check_caravan_robbery_with_decide(guild_id)
      result = check_caravan_robbery(guild_id)
      
      # Если вероятность равна 0, возвращаем как есть
      return result if result[:probability] == 0
      
      # Генерируем случайное число и решаем, ограблен ли караван
      random_value = rand
      robbed = random_value < result[:probability]
      
      Rails.logger.debug("Caravan robbery decision: probability=#{result[:probability]}, random=#{random_value}, robbed=#{robbed}")
      
      result.merge(robbed: robbed, random_value: random_value)
    end
    
    def create_caravan(params)
      caravan = Caravan.create!(
        country_id:        params[:country_id],
        guild_id:          params[:guild_id],
        year:              GameParameter.current_year,
        resources_export: params[:incoming],
        resources_import: params[:outcoming],
        gold_export:      params[:purchase_cost],
        gold_import:      params[:sale_income],
        via_vyatka:        params[:via_vyatka] || false
      )
      
      { success: true, caravan: caravan }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, error: e.message }
    rescue => e
      { success: false, error: e.message }
    end
  end


end
