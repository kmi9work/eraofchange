class Resource < ApplicationRecord
#params
#sale_price - цена продажи
#buy_price - цена покупки
#Если цена - nil - то он не продаётся или не покупается

belongs_to :country, optional: true

# Посчитать стоимость (метод с тремя параметрами:
#   купить/продать, сколько, какого ресурса) -
#    на выходе стоимость. Если эмбарго - то выводить ошибку

  def cost_calculator(transaction_type, number, resource)
    relations = resource.country.params["relations"].to_s
    unless resource.country.params['embargo']
      if transaction_type == "buy"
        unit_cost = resource.params["buy_price"][relations]
          if unit_cost != nil
            cost = unit_cost*number
            return cost
          else
            "Этот ресурс не продается на рынке"
          end
      else
        unit_cost = resource.params["sale_price"][relations]
        cost = unit_cost*number

        return cost
      end
    else
      'Этот ресурс не продается и не покупается из-за эмбарго'
    end
  end

# Посмотреть цены (Увидеть изменение цены) С учётом Эмбарго - На входе ничего.
# На выходе массив, в котором каждый элемент -
# это {resource_id: 1, buy_price: 123, sell_price: 68}. Если ресурс под эмбарго -
#  то nil в цене покупки в цене продажи.


  def show_prices
    resources = Resource.all
    array = []

    resources.each do |res|
        relations = res.country.params["relations"].to_s
          unless res.country.params["embargo"]
            buy_price = res.params["buy_price"][relations]
            sell_price = res.params["sale_price"][relations]
          else
            buy_price = nil
            sell_price = nil
          end

        res_prices = {}
        res_prices["resource_id:"] = res.id
        res_prices["buy_price:"] = buy_price
        res_prices["sell_price:"] = sell_price
        array.push(res_prices)
        end

    return array
  end



end

