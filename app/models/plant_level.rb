class PlantLevel < ApplicationRecord
  belongs_to :plant_type, optional: true
  has_many :plants

  def feed_to_plant!(request, way)
    #request = make_hash_with_indiff(request) TODO
    request.map! {|req| req.transform_keys(&:to_s)}
    resulting_from, resulting_to = [], []
    formulas.each do |formula|
      from, to  = count_request(formula, request, way)
      if way == "from"
        res_array_sum!(request, from, -1)
      else
        res_array_sum!(request, to, -1)
      end

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
    bucket = formula[way].deep_dup
    formula_part = formula[way]

    while is_res_array_less?(bucket, request) && is_res_array_less?(res_array_mult(formula["to"], n+1), formula['max_product'])
      res_array_sum!(bucket, formula_part.deep_dup)
      n += 1
    end

    to = res_array_mult(formula["to"], n)
    from = res_array_mult(formula["from"], n)

    return from, to
  end

  # Проверяет, не превышает ли количество хоть одного ресурса во втором массиве количество такого же ресурса в первом.
  # Если превышает - false. Если нет совпадений - false. 

  def is_res_array_less?(res_array1, res_array2)
    res_array1.each do |res1|
      var = res_array2.find {|res2| res1["identificator"] == res2["identificator"]}
      return false if var.blank?
      return false if res1["count"] > var["count"]
    end
    return true
  end

  #Умножает массив ресурсов на число
  def res_array_mult(res_array, n)
    res_array.deep_dup.each {|res| res["count"] *= n}
  end


  def res_array_sum!(array_1, array_2, sign = 1)
    arr2 = array_2.deep_dup
    array_1.each do |res_1|
      arr2.delete_if do |res_2|
        res_1["identificator"] == res_2["identificator"] && res_1['count'] += res_2['count']*sign
      end
    end

    array_1.concat(arr2)
  end
end
