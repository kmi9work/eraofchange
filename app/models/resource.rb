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
    return GameParameter.find(GameParameter::CURRENT_PRICES).params unless GameParameter.find(GameParameter::CURRENT_PRICES).params.empty?
    return Resource.define_prices
  end

  def self.define_prices
  off_market = [] # То, что покупается с рынка
  to_market = [] # То, что продается на рынок

  foreign_countries = Country.foreign_countries.as_json(only: [:id, :name])

  sell_res = []
  buy_res = []

  Resource.all.each do |resource|
    next if resource.country_id.nil?
    
    # Добавляем в продажу только если есть цены продажи
    if resource.params['sale_price'] && !resource.params['sale_price'].value?(nil)
      sell_res.push({
        name: resource.name, 
        identificator: resource.identificator, 
        sale_price: resource.params['sale_price']
      })
    end
    
    # Добавляем в покупку только если есть цены покупки
    if resource.params['buy_price'] && !resource.params['buy_price'].value?(nil)
      buy_res.push({
        name: resource.name, 
        identificator: resource.identificator, 
        buy_price: resource.params['buy_price']
      })
    end
  end

  # Распределяем sell_res по странам
  n = 0
  sell_res.shuffle!
  sell_res.each_with_index do |resource, i|
    country_index = n % foreign_countries.length
    off_market << resource.merge({country: foreign_countries[country_index]})
    n += 1
  end

  # Распределяем buy_res по странам
  n = 0
  buy_res.shuffle!
  buy_res.each_with_index do |resource, i|
    country_index = n % foreign_countries.length
    to_market << resource.merge({country: foreign_countries[country_index]})
    n += 1
  end

  game_parameter = GameParameter.find(GameParameter::CURRENT_PRICES)
  game_parameter.params = { off_market: off_market, to_market: to_market }
  game_parameter.save
  return { off_market: off_market, to_market: to_market }
end



end

