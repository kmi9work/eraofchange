class Resource < ApplicationRecord
  #params
  #sale_price - цена продажи рынком игроку
  #buy_price - цена покупки рынком у игрока
  #Если цена - nil - то он не продаётся или не покупается

  belongs_to :country, optional: true

  def self.country_filter(country_id, resources)
    resources.select do |res|
      Resource.where(country_id: country_id).any?{|r| r[:identificator] == res[:identificator]}
    end
  end

  def self.send_caravan(country_id, res_pl_sells = [], res_pl_buys = [], gold = 0)
   #ресурсы, которые игрок продает рынку
    gold = res_pl_sells.select {|d|  d[:identificator] == "gold"}[0][:count] || 0
    elig_resources = country_filter(country_id, res_pl_sells)
    elig_resources.each do |res|
      #ПРОВЕРИТЬ ПОТОМ ВНИМАТЕЛЬНЕЕ
      gold += calculate_cost("buy", res[:count], Resource.find_by(identificator: res[:identificator]))[:cost]
    end

    res_to_player = []
    elig_resources = country_filter(country_id, res_pl_buys)
    elig_resources.each do |res|
      resource = calculate_cost("sale", res[:count], Resource.find_by(identificator: res[:identificator]))
      gold -= resource[:cost]
      res_to_player.push({name: Resource.find_by(identificator: resource[:identificator]).name,
                          identificator: resource[:identificator],
                          count: resource[:count].to_i})
    end
    gold_as_res = Resource.find_by(identificator: "gold")
    res_to_player.push({name: gold_as_res.name, identificator: gold_as_res.identificator, count: gold})


    #/ПРОВЕРИТЬ ПОТОМ ВНИМАТЕЛЬНЕЕ
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

