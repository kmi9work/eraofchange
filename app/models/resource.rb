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

  def self.send_caravan(country_id, resources_to_buy = [], resource_to_sell = [])
    result = []
    resources_to_buy.map! {|res| res.transform_keys(&:to_sym)} ########
    if resources_to_buy.present? #Если мы покупаем у игрока
      transaction_type = "buy"
      resources = country_filter(country_id, resources_to_buy)
    elsif resource_to_sell.present?
      resource_to_sell.map! {|res| res.transform_keys(&:to_sym)} #######
      transaction_type = "sale" #Если мы продаем игроку
      resources = country_filter(country_id, resource_to_sell)
    end

    resources.each do |res|
      result.push(
        calculate_cost(transaction_type, 
                      res[:count], 
                      Resource.find_by(identificator: res[:identificator]))
      )
    end

    return result
  end

  # cost: nil - значит, что ресурс не продаётся на рынке
  def self.calculate_cost(transaction_type, amount, resource)
    relations = resource.country.params["relations"].to_s
    unit_cost = resource.params["#{transaction_type}_price"][relations.to_s]
    if unit_cost
      {identificator: resource.identificator, cost: unit_cost*amount, embargo: resource.country.params["embargo"]}
    else
      {identificator: resource.identificator, cost: nil, embargo: resource.country.params["embargo"]}
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

