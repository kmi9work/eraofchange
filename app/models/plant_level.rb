class PlantLevel < ApplicationRecord
    belongs_to :plant_type, optional: true
    has_many :plants

    # def formula
    #   return self[:formulas] if self[:formulas].is_a?(HashWithIndifferentAccess)
    #   self[:formulas] = HashWithIndifferentAccess.new(self[:formulas][0])
    # end

  def feed_to_plant(resources_from = [], resources_to = nil)
    if plant_type.plant_category_id == PlantCategory::EXTRACTIVE
      return formulas[0]["max_product"]
    end

    if resources_to != nil
      result_to = self.choose_prod_path(resources_to, "to")
    elsif resources_to == nil
      result_from = self.choose_prod_path(resources_from, "from")
    end
  end

  def choose_prod_path(request, way)
    formulas = self.formulas.deep_dup
    from, to, resulting_resources = [], [], {}
      formulas.each do |form|
        num  = self.count_request(way, request, [form])

        all_res = self.produce([form], request, num, way)

        resulting_resources = {from: self.compress(from.push(all_res[:from])),
                               to: self.compress(to.push(all_res[:to])),
                               change: request }
      end

    return resulting_resources
   end

  def count_request(way, request, incoming_formula)
    n = 0
    formula = incoming_formula[0][way]
    bucket = incoming_formula[0][way].deep_dup

    #request = make_hash_with_indiff(request)
    request.map! {|req| req.transform_keys(&:to_s)}

    while is_res_array_less?(bucket, request)
      break if max_reached?(n, incoming_formula)
      res_array_sum(bucket, formula, 1)
      n += 1
    end
    return n
  end

  def produce(incoming_formula, request, n, way)
    to = res_array_mult(incoming_formula[0]["to"].deep_dup, n)
    from = res_array_mult(incoming_formula[0]["from"].deep_dup, n)

    self.res_array_sum(request, from, -1)
    self.res_array_sum(request, to, -1)

    result = {from: from, to: to}
  end

#Проверяет, больше ли "ведро" запроса
  def is_res_array_less?(bucket, request)
    result = true
    checks = []
    bucket.each do |res_in_bucket|
      request.each do |res_in_request|
        if res_in_bucket["identificator"] == res_in_request["identificator"]
          checks.push(res_in_bucket["count"] <= res_in_request["count"])
        end
      end
    end
    result = false if checks.include?(false) or checks.empty?
    return result
  end

  def res_array_sum(add_to, what_to_add, sign)
    add_to.each do |add_to_res|
      what_to_add.each do |what_to_add_res|
        add_to_res["count"] += (what_to_add_res["count"]*sign) if add_to_res["identificator"] == what_to_add_res["identificator"]
      end
    end
  end

#Умножает формулу на количество вхождений формулы в "ведро"
  def res_array_mult(formula1, n)
    formula1.each {|res| res["count"] *= n}
  end

  def max_reached?(n, incoming_formula)
    reached = false
    form = incoming_formula[0]["to"][0]["count"] * n
    reached = true if incoming_formula[0]["max_product"][0]["count"] <= form
    return reached
  end

  def compress(res)
    res.flatten!
    array, result = [], []
    res.each {|ids| array.push(ids["identificator"]) unless array.include?(ids["identificator"])}

    array.each do |res_id|
      count = 0
      res.each {|res_count| count += res_count["count"] if res_count["identificator"] == res_id}
      result.push({"identificator" => res_id, "count" => count})
    end

    return result
  end

end





#
  # def make_hash_with_indiff(arrayed_hash)
  #   new_array = []
  #   arrayed_hash.select {|hash| new_array.push(HashWithIndifferentAccess.new(hash))}
  #   return new_array
  # end




