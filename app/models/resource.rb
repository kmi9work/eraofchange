class Resource < ApplicationRecord
  #params
  #sale_price - цена продажи рынком игроку
  #buy_price - цена покупки рынком у игрока
  #Если цена - nil - то он не продаётся или не покупается

  belongs_to :country, optional: true

  validates :identificator, uniqueness: { scope: :country_id }, presence: true

  TARIFF = 1.20

  # Artel: ресурсы без страны и особая логика цен.
  # В dev может случиться, что Engine-хук не успевает подмешать concern до первого запроса.
  # Подмешиваем здесь гарантированно, если активна игра Artel.
  if ENV["ACTIVE_GAME"] == "artel"
    begin
      if defined?(Artel::Engine)
        require_dependency Artel::Engine.root.join("app", "models", "artel", "concerns", "resource_extensions.rb").to_s
      end
      if defined?(Artel::Concerns::ResourceExtensions) && !included_modules.include?(Artel::Concerns::ResourceExtensions)
        include Artel::Concerns::ResourceExtensions
      end
    rescue => e
      Rails.logger.warn("[Artel] Failed to include ResourceExtensions: #{e.class}: #{e.message}") if defined?(Rails)
    end
  end

  def self.country_filter(country_id, resources)
    resources.select do |res|
      Resource.where(country_id: country_id).any?{|r| r[:identificator] == res[:identificator]}
    end
  end

  def self.send_caravan(country_id, res_pl_sells = [], res_pl_buys = [])
    # Валидация входных данных
    raise ArgumentError, "country_id is required" if country_id.blank?
    raise ArgumentError, "res_pl_sells must be an array" unless res_pl_sells.is_a?(Array)
    raise ArgumentError, "res_pl_buys must be an array" unless res_pl_buys.is_a?(Array)
    
    # Извлекаем золото из ресурсов, которые игрок продает рынку
    gold_item = res_pl_sells.find {|d| d[:identificator] == "gold"}
    gold = gold_item&.dig(:count) || 0
    # Обрабатываем ресурсы, которые игрок продает рынку
    elig_resources = country_filter(country_id, res_pl_sells)
    elig_resources.each do |res|
      next if res[:identificator] == "gold" # Пропускаем золото, оно уже обработано
      next unless res[:count] && res[:count] > 0 # Пропускаем пустые значения
      
      resource_obj = Resource.find_by(identificator: res[:identificator])
      next unless resource_obj # Пропускаем несуществующие ресурсы
      
      cost_result = calculate_cost("buy", res[:count], resource_obj)
      gold += cost_result[:cost] if cost_result[:cost]
    end

    # Обрабатываем ресурсы, которые игрок покупает с рынка
    res_to_player = []
    elig_resources = country_filter(country_id, res_pl_buys)
    elig_resources.each do |res|
      next unless res[:count] && res[:count] > 0 # Пропускаем пустые значения
      
      resource_obj = Resource.find_by(identificator: res[:identificator])
      next unless resource_obj # Пропускаем несуществующие ресурсы
      
      cost_result = calculate_cost("sale", res[:count], resource_obj)
      next unless cost_result[:cost] # Пропускаем ресурсы, которые нельзя купить
      
      gold -= cost_result[:cost]
      res_to_player.push({
        name: resource_obj.name,
        identificator: resource_obj.identificator,
        count: cost_result[:count].to_i
      })
    end
    
    # Добавляем итоговое золото к результату
    gold_as_res = Resource.find_by(identificator: "gold")
    if gold_as_res && gold != 0
      res_to_player.push({
        name: gold_as_res.name, 
        identificator: gold_as_res.identificator, 
        count: gold
      })
    end

    return {res_to_player: res_to_player}
  end

  # cost: nil - значит, что ресурс не продаётся на рынке
  def self.calculate_cost(transaction_type, amount, resource)
    relations = resource.country&.relations.to_s
    unit_cost = resource.params["#{transaction_type}_price"][relations]
    if unit_cost
      {identificator: resource.identificator, count: amount, cost: unit_cost*amount.to_i, embargo: resource.country.params[0]["embargo"]}
    else
      {identificator: resource.identificator, count: amount,  cost: nil, embargo: resource.country.params[0]["embargo"]}
    end
  end

  def self.show_prices
    resources = Resource.all

    off_market = [] # То, что продается с рынка (покупает игрок)
    to_market =  [] # То, что продается на рынок (продает игрок)

    resources.each do |res|
      # Определяем отношения (0 для ресурсов без страны)
      if res.country_id.nil?
        relations = "0"
      else
        relations = res.country.relations.to_s
      end

      # Базовая структура для цен
      to_prices = {
        name: res.name,
        identificator: res.identificator
      }
      
      off_prices = {
        name: res.name,
        identificator: res.identificator
      }

      # Добавляем информацию о стране если есть
      if res.country_id
        to_prices[:country] = res.country.as_json(only: [:id, :name])
        to_prices[:embargo] = res.country.params["embargo"] if res.country.params
        
        off_prices[:country] = res.country.as_json(only: [:id, :name])
        off_prices[:embargo] = res.country.params["embargo"] if res.country.params
      else
        # Для ресурсов без страны
        to_prices[:country] = nil
        to_prices[:embargo] = 0
        to_prices[:country_id] = nil
        
        off_prices[:country] = nil
        off_prices[:embargo] = 0
        off_prices[:country_id] = nil
      end

      # Проверяем и добавляем цену продажи на рынок (игрок продает)
      if res.params["buy_price"] && res.params["buy_price"][relations]
        to_prices[:sell_price] = res.params["buy_price"][relations]
        to_market.push(to_prices)
      end

      # Проверяем и добавляем цену покупки с рынка (игрок покупает)
      if res.params["sale_price"] && res.params["sale_price"][relations]
        off_prices[:buy_price] = res.params["sale_price"][relations]
        off_market.push(off_prices)
      end
    end

    off_and_to_market_prices = { off_market: off_market, to_market: to_market }

    # Проверяем эффект HIGHER_SELL_PRICES для текущего года
    if GameParameter.any_lingering_effects?("higher_sell_prices", GameParameter.current_year) 
      return Resource.increase_prices(off_and_to_market_prices) 
    else 
      return off_and_to_market_prices 
    end
  end

  private
  def self.increase_prices(hashed_array)
    hashed_array[:to_market].each do |resource|
      resource[:sell_price] = (resource[:sell_price] * TARIFF).floor
    end
    hashed_array
  end


end

