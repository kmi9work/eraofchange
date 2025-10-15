class Resource < ApplicationRecord
  #params
  #sale_price - цена продажи рынком игроку
  #buy_price - цена покупки рынком у игрока
  #Если цена - nil - то он не продаётся или не покупается

  belongs_to :country, optional: true

  def self.shuffle_resources!
    foreign_countries_ids = Country.foreign_countries.map {|c| c.id }
    resources = Resource.all 
    resources.each do |res |
      res.country_id =  foreign_countries_ids.shuffle!.pop unless foreign_countries_ids.empty?
      res.save
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
      {identificator: resource.identificator, count: amount, cost: unit_cost*amount.to_i, embargo: resource.country.params["embargo"]}
    else
      {identificator: resource.identificator, count: amount,  cost: nil, embargo: resource.country.params["embargo"]}
    end
  end

  def self.show_prices
    resources = Resource.all

    off_market = [] # То, что продается с рынка
    to_market =  [] # То, что продается на рынок

    off_and_to_market_prices = {off_market: off_market, to_market: to_market} # хэш с данным для покупки и продажи

    prices_array = []

    resources.each do |res|
      next if res.country_id == nil
      relations = res.country.relations.to_s

      not_for_sale = true if res.params["sale_price"][relations] == nil

      to_prices =  {}
      off_prices = {}

      to_prices[:name]  = res.name
      off_prices[:name] = res.name

      to_prices[:identificator]  = res.identificator
      off_prices[:identificator] = res.identificator

      to_prices[:sell_price] = res.params["buy_price"][relations] #игрок продает на рынок
      off_prices[:buy_price] = res.params["sale_price"][relations]  #игрок покупает на рынке

      to_prices[:embargo]  = res.country.params["embargo"]
      off_prices[:embargo] = res.country.params["embargo"]


      to_prices[:country]  = res.country.as_json(only: [:id, :name])
      off_prices[:country] = res.country.as_json(only: [:id, :name])

      to_market.push(to_prices)
      off_market.push(off_prices) if !not_for_sale

    end

    return off_and_to_market_prices
  end

end

