class Resource < ApplicationRecord
  #params
  #sale_price - цена продажи рынком игроку
  #buy_price - цена покупки рынком у игрока
  #Если цена - nil - то он не продаётся или не покупается

  belongs_to :country, optional: true

  def self.country_filter(country_id, resources)
    resources.select! do |res|
      (Resource.where(country_id: country_id)).any?{|r| r[:identificator] == res[:identificator]}
    end
  end

  def self.send_caravan(country_id, resources_to_buy = [], resource_to_sell = [])
    result = []
    if resources_to_buy.present? #Если мы покупаем у игрока
      transaction_type = "buy"
      resources = country_filter(country_id, resources_to_buy)
    elsif resource_to_sell.present?
      transaction_type = "sell" #Если мы продаем игроку
      resources = country_filter(country_id, resource_to_sell)
    end

      all_resources = Resource.all
      resources.each do |res|
        result.push(Resource.calculate_cost(transaction_type, res[:count], all_resources.find_by(identificator: res[:identificator])))
      end

    return result
  end


  def self.calculate_cost(transaction_type, amount, resource)
    relations = resource.country.params["relations"].to_s
      if transaction_type == "sell"
        unit_selling_cost = resource.params["sale_price"][relations.to_s]
          if unit_selling_cost != nil
            cost = unit_selling_cost*amount
          else
            return {cost: nil, embargo: resource.country.params["embargo"], msg: "Этот ресурс не продается на рынке."}
          end
      elsif transaction_type == "buy"
          unit_buying_cost = resource.params["buy_price"][relations.to_s]

          if unit_buying_cost != nil
            cost = unit_buying_cost*amount
          else
            return {cost: nil, embargo: resource.country.params["embargo"], msg: "Этот ресурс не покупается на рынке."}
          end
      end

      if resource.country.params["embargo"]
         return {cost: cost, embargo: true, msg: "Этот ресурс под эмбарго. Для его покупки/продажи нужна контрабанда."}
      else
         return {cost: cost, embargo: false, msg: "Этот ресурс продается свободно."}
      end
  end

  def self.show_prices
    resources = Resource.all
    prices_array = []

    resources.each do |res|
      next if res.country_id == nil
      relations = res.country.params["relations"].to_s

      res_prices = {}
      res_prices[:resource_id] = res.id
      res_prices[:buy_price] = res.params["buy_price"][relations]
      res_prices[:sell_price] = res.params["sale_price"][relations]
      res_prices[:embargo] = res.country.params["embargo"]
      prices_array.push(res_prices)
    end

    return prices_array
  end

end

