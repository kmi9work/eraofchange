class Resource < ApplicationRecord
#params
#sale_price - цена продажи рынком игру
#buy_price - цена покупки рынком у игрока
#Если цена - nil - то он не продаётся или не покупается

belongs_to :country, optional: true


  def calculate_cost(transaction_type, amount, resource)
    relations = resource.country.params["relations"].to_s
      if transaction_type == "sell"
        unit_cost = resource.params["sale_price"][relations]
          if unit_cost != nil
            cost = unit_cost*amount
          else
            return {cost: nil, embargo: resource.country.params["embargo"], msg: "Этот ресурс не продается на рынке."}
          end
      else
        unit_cost = resource.params["buy_price"][relations]
        cost = unit_cost*amount
      end

      if resource.country.params["embargo"]
          {cost: cost, embargo: true, msg: "Этот ресурс под эмбарго. Для его покупки/продажи нужна контрабанда."}
      else
          {cost: cost, embargo: false, msg: "Этот ресурс продается свободно."}
      end
  end

  def show_prices
    resources = Resource.all
    prices_array = []

    resources.each do |res|
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

