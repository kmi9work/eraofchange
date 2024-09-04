class PlantLevel < ApplicationRecord
    belongs_to :plant_type, optional: true
    has_many :plants

   # serialize :formula, ActiveSupport::HashWithIndifferentAccess

   # MAX_LEVEL = 3

  # Общая структура формулы производства:
  # formula: {
  #   from: [
  #     {resource_id: id, count: 1}, ...
  #   ],
  #   to: [
  #     {resource_id: id, count: 2}, ...
  #   ],
  #   max: [
  #     {resource_id: id, count: 100}, ...
  #   ]
  # }
  #
  # Пример 1: из 6 досок(id 1) и 1 металла (id 2) и 300 золота (id 3) сделать один инструмент (id 10):
  # formula: {
  #   from: [
  #     {resource_id: 1, count: 6},
  #     {resource_id: 2, count: 1},
  #     {resource_id: 3, count: 300}
  #   ],
  #   to: [
  #     {resource_id: 10, count: 1}
  #   ],
  #   max: [
  #     {resource_id: 10, count: 20}
  #   ]
  # }
  #
  # Пример 2: Добывающая делянка первого уровня (оплата 100 золота, производство 100 дерева id 4):
  # formula: {
  #   from: [
  #     {resource_id: 3, count: 100}
  #   ],
  #   to: [
  #     {resource_id: 4, count: 100}
  #   ],
  #   max: [
  #     {resource_id: 4, count: 100}
  #   ]
  # }
  # def produce(resources_from, resources_to = nil)
  #   # Необходимо осуществить производство ресурса в соответствии с формулой, хранящейся в классе.
  #   # Если есть ожидаемые ресурсы (например, в Кузнице) Проверяется - возможно ли произвести ожидаемые ресурсы. То, что не получается
  #   # по формуле или выше максимума - вернуть в сдачу.
  #   # Если resources_to.blank? то нужно посчитать сколько можно произвести ресурсов из resources_from (в кузнице тогда производить
  #   # в первую очередь инструменты, потом оружие, на оставшиеся - доспехи)
  #   # Пример работы:
  #   # pl = PlantLevel.last
  #   # pl.produce([
  #   #   {resource_id: 1, count: 60},
  #   #   {resource_id: 2, count: 10},
  #   #   {resource_id: 3, count: 300}
  #   # ])
  #   # =>
  #   # [{resource_id: 10, count: 10}]

  #   # Другой пример (допустим, инструменты производятся из 6 досок и одного металла, а одни доспехи (id 11) из 5 металла)
  #   # Запрос - 10 инструмента и один доспех. Ресурсы 60 досок, 20 металла и 300 монет
  #   # Тогда программа должна выдать 10 инструментов, один доспех и 5 металла сдачи
  #   # pl.produce([
  #   #   {resource_id: 1, count: 60},
  #   #   {resource_id: 2, count: 20},
  #   #   {resource_id: 3, count: 300}
  #   # ], [
  #   # {resource_id: 10, count: 10},
  #   # {resource_id: 11, count: 1}
  #   # ])
  #   # =>
  #   # [{resource_id: 10, count: 10}, {resource_id: 11, count: 1}, {resource_id: 2, count: 5}]
  # end

###########решить с символами. доделать описание. протестировать все предприятия.

  def feed_to_plant(resources_from = [], resources_to = nil)
    resources_from_dup = resources_from.dup
    resources_to_dup = resources_to.dup
    if plant_type.plant_category_id == PlantCategory::EXTRACTIVE
      return formula["max_product"]
    end

    if resources_from_dup != []
      filter!(resources_from_dup, 'from')
      return foundry_prod(resources_from_dup) if formula[:logic] == :or
      f, done = define_formula[:from], false

      f.each do |res|
        done = false
        resources_from_dup.each do |res_add|
          if res[:identificator] == res_add[:identificator]
            res[:count] = res_add[:count]
            done = true
            break
          end
        end
        break if done == false
      end

      if done
        return produce({from: f})
      else
        return {result: nil, msg: "Недостаточно ресурсов для переработки"}
      end
    end

    if resources_to_dup.present?
      result = []
      filter!(resources_to_dup, 'to')
      return {result: nil, msg: "Нет необходимых ресурсов"} if resources_to_dup.empty?
      resources_to_dup.each {|cl_r| result.push(produce({to: [cl_r]}))}

      return result
     end
  end

  def foundry_prod(cl_resources_from)
      needed_formulas = []
      result = []
      formula["from"].each do |f|
        re = 0
        cl_resources_from.each do |res|
          if f["identificator"] == res[:identificator] ### -=-
            num_of_res = formula["from"].index(f)
            re = formula["from"][num_of_res]
            needed_formulas.push(re.transform_keys(&:to_sym))
            #re = re.transform_keys(&:to_sym)
          end
        end
      end

      needed_formulas.each do |form|
        cl_resources_from.each do |res_add|
          if form[:identificator] == res_add[:identificator]
            form[:count] = res_add[:count]
          end
        end
        result.push(produce({from: [form]}))
      end
    return result
  end

  def produce(hashed_request = nil)
    if hashed_request[:to].blank?
      #Выдает только то, сколько можно сделать ресурса из входящего сырья
      return multi_prod(hashed_request[:from])
    elsif hashed_request[:to].present? #(если to имеется)
       #Отправляет ресурс на разборку
      return add_hash(hashed_request[:to])
    end
  end

  def multi_prod(hashed_var, target_res = nil)
    end_prod = [{identificator: "empty", count: 0}]

    if target_res == nil
      end_prod[0][:identificator] = define_formula[:to][0][:identificator]
    else
      end_prod[0][:identificator] = target_res
    end

    return special_prod(hashed_var)                            if type_of_production[:production_type] == 3
    return forge_prod(hashed_var)                              if plant_type_id == PlantType::FORGE && target_res.blank?

    return sub_hash(hashed_var, end_prod, target_res = nil)
   end

  def special_prod(hashed_var)
    count = 0
    froms = formula["from"]
    for i in 0..froms.length-1
      count = i if froms[i].key(hashed_var[0][:identificator]).present?
    end

    tos = formula["to"]
    target_res = tos[count]["identificator"]

    end_prod = [{identificator: target_res, count: 0}]
    return sub_hash(hashed_var, end_prod)
  end

  def sub_hash(hashed_var, end_prod, target_res = nil)
    if target_res != nil
      formula = define_formula(target_res)[:from]
    else
      target_res = end_prod[0][:identificator]
      formula = define_formula(target_res)[:from]
    end

    done = false

    until done
      for i in 0..hashed_var.length-1
        if (hashed_var[i][:count] - formula[i][:count] < 0) or
           (end_prod[0][:count] + define_formula[:to][0][:count] > define_formula(target_res)[:max_product][0][:count])
          done = true
          break
        end
      end
      hashed_var[i][:count] -= formula[i][:count]           if hashed_var[i][:identificator] == formula[i][:identificator]
      end_prod[0][:count] += define_formula[:to][0][:count]
    end

  return end_prod
  end

  def forge_prod(hashed_var, target_res = nil)
    result = []
    formula["to"].map{|res| res['identificator']}.each do |target_res|
      end_prod = [{identificator: target_res, count: 0}]
      result.push(sub_hash(hashed_var, end_prod, target_res))
    end

    return result
  end

  def add_hash(hashed_var)
      target_res = hashed_var[0][:identificator]
      formula = define_formula(target_res)

      res_back = formula[:from][0][:identificator]
      raw_resources = []
      formula[:from].each {|res| raw_resources.push({identificator: res[:identificator], count: 0})}

      if hashed_var[0][:count] >= define_formula(target_res)[:max_product][0][:count]
        max = define_formula(target_res)[:max_product][0][:count]
      else
        max = hashed_var[0][:count]
      end

      step = define_formula(target_res)[:to][0][:count]
    ############ беспонтово
      for j in 0..(max-1)/step
        for i in 0..raw_resources.length-1
          a = (formula[:from][i][:count]*step)
          raw_resources[i][:count] += a    #  if hashed_var[i][:identificator] == formula[i][:identificator]
        end
      end

    return raw_resources
  end

  def filter!(resources, way)
    resources.select! do |res|
      formula[way].any?{|r| r['identificator'] == res[:identificator]}
    end
  end

  def type_of_production
    raw_res_to_prod_ratio = formula["from"].count/formula["max_product"].count
    production_type = 1 if formula["max_product"].count == 1                       #То есть из 1 рес в 1 рес
    production_type = 2 if formula["max_product"].count < formula["from"].count   #Кузница
    production_type = 3 if formula["max_product"].count == formula["from"].count && formula["max_product"].count > 1 # Плавильня
    return {production_type: production_type, ratio: raw_res_to_prod_ratio}
  end

  def define_formula(target_res = nil)
    target_res = formula["to"][0]["identificator"] if target_res.blank?
    array = []
    ratio = type_of_production[:ratio]
    formula_from = formula["from"][res_index_to(target_res) * ratio, ratio]
    formula_to   = (formula["to"][res_index_to(target_res)]).transform_keys(&:to_sym)
    formula_from.each{|f| array.push(f.transform_keys(&:to_sym)) } #if f["count"] != 0}
    max = []
    max.push((formula["max_product"][res_index_to(target_res)]).transform_keys(&:to_sym))


    return {from: array, to: [formula_to], max_product: max}
  end


  #Определяет по тому ресурсу, КОТОРЫЙ НАДО произвести
  def res_index_to(name_of_res)
    formula["to"].find_index{|res| res["identificator"] == name_of_res}
  end
end
