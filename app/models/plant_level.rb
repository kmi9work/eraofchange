class PlantLevel < ApplicationRecord
  belongs_to :plant_type, optional: true
  has_many :plants
  MAX_LEVEL = 3


  include Dictionary

  def self.show_pl_levels
    pl_levels = []
    formula_from = []
    formula_to = []
    PlantLevel.all.each do |p_l|
      next if p_l.plant_type.plant_category.id == PlantCategory::EXTRACTIVE
      pl_levels.push({id: p_l.id,
                      formula_from: p_l.formula_conversion[:from],
                      formula_to:   p_l.formula_conversion[:to],
                      name: p_l.plant_type.name,
                      level: p_l.level
                    })
    end
    return pl_levels
  end

  def self.show_pl_levels_full
    pl_levels = []
    tech_schools_open = Technology.find(Technology::TECH_SCHOOLS).is_open == 1
    
    PlantLevel.all.each do |p_l|
      # Для добывающих предприятий используем только formula_to
      if p_l.plant_type.plant_category.id == PlantCategory::EXTRACTIVE
        pl_levels.push({id: p_l.id,
                        formula_from: [],
                        formula_to:   p_l.formula_conversion[:to],
                        formulas:     [],
                        name: p_l.plant_type.name,
                        level: p_l.level,
                        tech_schools_open: tech_schools_open
                      })
      else
        pl_levels.push({id: p_l.id,
                        formula_from: p_l.formula_conversion[:from],
                        formula_to:   p_l.formula_conversion[:to],
                        formulas:     p_l.formulas,
                        name: p_l.plant_type.name,
                        level: p_l.level,
                        tech_schools_open: tech_schools_open
                      })
      end
    end
    return pl_levels
  end

  def formula_conversion
    to, from = [], []
    # Для добывающих предприятий formulas может быть пустым или nil
    return {from: [], to: []} if self.formulas.nil? || self.formulas.empty?
    
    self.formulas.each do |res|
      res["from"].each{|uu| from.push({name: look_up_res(uu["identificator"]), identificator: uu["identificator"], count: uu["count"]})} if res["from"]
      res["to"].each{|ii|   to.push({name: look_up_res(ii["identificator"]), identificator:   ii["identificator"], count: ii["count"]})} if res["to"]
    end
    # Убираем дубликаты по identificator, оставляя первое вхождение
    return {from: from.uniq { |item| item[:identificator] }, to: to.uniq { |item| item[:identificator] }}
  end

  def feed_to_plant!(request = [], way = 'from')
    Technology.find(Technology::TECH_SCHOOLS).is_open == 1 ? coof = 1.5 : coof = 1

    #request = make_hash_with_indiff(request) TODO
    request.map! {|req| req.transform_keys(&:to_s)}
    request.map do |req|
      req["count"] = req["count"].to_i
      (req["count"] /= coof).ceil if way == "to"
      req[:name] = look_up_res(req["identificator"])
    end

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

    resulting_to.each{|res| res["count"] *= coof}

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
    res_array.deep_dup.each do |res|
     res["count"] *= n
     res.merge!({name: look_up_res(res["identificator"])})
    end
  end


  def res_array_sum!(array_1, array_2, sign = 1)
    arr2 = array_2.deep_dup
    array_1.each do |res_1|
      arr2.delete_if do |res_2|
        res_1["identificator"] == res_2["identificator"] && res_1["count"] += res_2["count"]*sign
      end
    end

    array_1.concat(arr2)
  end
end
