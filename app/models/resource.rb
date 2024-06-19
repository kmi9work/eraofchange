class Resource < ApplicationRecord
#params
#sale_price - цена продажи
#buy_price - цена покупки
#Если цена - nil - то он не продаётся или не покупается

belongs_to :country, optional: true


  def calculate_cost(transaction_type, number, resource)
    relations = resource.country.params["relations"].to_s
    unless resource.country.params['embargo']
      if transaction_type == "sell"
        unit_cost = resource.params["sale_price"][relations]
          if unit_cost != nil
            cost = unit_cost*number
            return cost
          else
            "Этот ресурс не продается на рынке"
          end
      else
        unit_cost = resource.params["buy_price"][relations]
        cost = unit_cost*number

        return cost
      end
    else
      'Этот ресурс не продается и не покупается из-за эмбарго'
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

