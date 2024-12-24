class PlantLevel < ApplicationRecord
  belongs_to :plant_type, optional: true
  has_many :plants

  def feed_to_plant!(request, way)
    #request = make_hash_with_indiff(request) TODO
    request.map! {|req| req.transform_keys(&:to_s)}
    resulting_from, resulting_to = [], []
    formulas.each do |formula|
      from, to  = count_request(formula, request, way)
      res_array_sum!(request, from, -1)
      res_array_sum!(request, to, -1)

      res_array_sum!(resulting_from, from)
      res_array_sum!(resulting_to, to)
    end

    return {
        from: resulting_from,
        to: resulting_to,
        change: request
    }
   end

  def count_request(formula, request, way)
    n = 0
    bucket = []
    formula_part = formula[way]

    while is_res_array_less?(bucket, request) && is_res_array_less?(bucket, formula['max_product'])
      res_array_sum!(bucket, formula_part)
      n += 1
    end
    to = res_array_mult(formula["to"], n)
    from = res_array_mult(formula["from"], n)

    return from, to
  end

  # Проверяет, не превышает ли количество хоть одного ресурса во втором массиве количество такого же ресурса в первом.
  # Если превышает - false. Если нет совпадений - false. 

  def is_res_array_less?(res_array1, res_array2)
    any_matches = false
    res_array1.each do |res1|
      res_array2.each do |res2|
        if res1["identificator"] == res2["identificator"]
          any_matches = true
          return false if res1["count"] > res2["count"]
        end
      end
    end
    return any_matches
  end

  def res_array_sum!(add_to, what_to_add, sign = 1)
    #Вставить сюда метод суммы Даши
    add_to.each do |add_to_res|
      what_to_add.each do |what_to_add_res|
        add_to_res["count"] += (what_to_add_res["count"]*sign) if add_to_res["identificator"] == what_to_add_res["identificator"]
      end
    end
  end

  #Умножает массив ресурсов на число
  def res_array_mult(res_array, n)
    res_array.deep_dup.each {|res| res["count"] *= n}
  end
end
