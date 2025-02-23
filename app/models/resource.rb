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
    return {msg: "Эмбарго"} if Country.find(country_id).params["embargo"]
    #TODO Инстурмент проверки наличия у игрока "Контрабанды"

    if res_pl_sells.present? #ресурсы, которые игрок продает рынку
      res_pl_sells.map! {|res| res.transform_keys(&:to_sym)} ####### Костыль сериализации
      elig_resources = country_filter(country_id, res_pl_sells)
      elig_resources.each do |res|
        gold += calculate_cost("sale", res[:count], Resource.find_by(identificator: res[:identificator]))[:cost]
      end
    end

    res_to_player = []
    res_pl_buys.map! {|res| res.transform_keys(&:to_sym)} ####### Костыль сериализации
    elig_resources = country_filter(country_id, res_pl_buys)
    elig_resources.each do |res|
      resource = calculate_cost("buy", res[:count], Resource.find_by(identificator: res[:identificator]))
      gold -= resource[:cost]
      res_to_player.push({identificator: resource[:identificator], count: resource[:count]})
    end

    return {res_to_player: res_to_player, gold: gold}
  end

  # cost: nil - значит, что ресурс не продаётся на рынке
  def self.calculate_cost(transaction_type, amount, resource)
    relations = resource.country.params["relations"].to_s
    unit_cost = resource.params["#{transaction_type}_price"][relations.to_s]
    if unit_cost
      {identificator: resource.identificator, count: amount, cost: unit_cost*amount, embargo: resource.country.params["embargo"]}
    else
      {identificator: resource.identificator, count: amount,  cost: nil, embargo: resource.country.params["embargo"]}
    end
  end

  def self.show_prices
    resources = Resource.all
    prices_array = []

    resources.each do |res|
      next if res.country_id == nil
      relations = res.country.params["relations"].to_s

      res_prices = {}
      res_prices[:identificator] = res.identificator
      res_prices[:buy_price] = res.params["buy_price"][relations]
      res_prices[:sell_price] = res.params["sale_price"][relations]
      res_prices[:embargo] = res.country.params["embargo"]
      prices_array.push(res_prices)
    end

    return prices_array
  end

end

