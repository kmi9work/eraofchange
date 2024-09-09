class PlantLevel < ApplicationRecord
    belongs_to :plant_type, optional: true
    has_many :plants

    def formula
      return self[:formula] if self[:formula].is_a?(HashWithIndifferentAccess)
      self[:formula] = HashWithIndifferentAccess.new(self[:formula])
    end


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
      return formula[:max_product]
    end

    if resources_from_dup != []
      filter!(resources_from_dup, 'from')
    return foundry_prod(resources_from_dup) if formula[:logic] == "or"

      f, done = self.define_formula("from"), false

      f_deep_dup = f.deep_dup

      f_deep_dup.each do |res|
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
        return produce({from: f_deep_dup})
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

  def filter!(resources, way = nil)
    resources.select! do |res|
      self.define_formula(way).any?{|r| r[:identificator] == res[:identificator]}
    end
    return resources
  end


  #Определяет по тому ресурсу, КОТОРЫЙ НАДО произвести
  def res_index_to(name_of_res)
    self.define_formula("to").find_index{|res| res["identificator"] == name_of_res}
  end



  def define_formula(way, target_res = nil)
   # target_res = formula["to"][0]["identificator"] if target_res.blank?
    if target_res.present?
      case self.formula["logic"]
       when nil   then return [self.formula[way][self.res_index_to(target_res)]]
       when "and", "or" then return self.formula[way][self.res_index_to(target_res)]
      end
    end

    case self.formula["logic"]
      when nil then return self.formula[way]
      when "and","or"
        return end_res.find {|f| f["identificator"] == target_res}              if target_res.present?
o = []
        end_res, already_theres = [], []
        self.formula[way].each do |form|
          form.each do |res|
             if already_theres.include?(res["identificator"])
              next
             else
                end_res.push(res)
               already_theres.push(res["identificator"])
            end
          end
        end

        return end_res
    end
  end

  def foundry_prod(cl_resources_from)
      result = []

      foundry_res = (self.formula[:from]).deep_dup

      foundry_res.each do |res|
        res.each do |res_1|
          cl_resources_from.each do |res_2|
            if res_1["identificator"] == res_2[:identificator]
              res_1["count"] = res_2[:count]
            end
         end
        end
        result.push(produce({from: res}))
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
    return special_prod(hashed_var)                           if self.formula[:logic] == "or"
    end_prod = [{identificator: "empty", count: 0}]

    if target_res == nil
      end_prod[0][:identificator] = define_formula("to")[0][:identificator]
    else
      end_prod[0][:identificator] = target_res
    end


    return forge_prod(hashed_var)                              if plant_type_id == PlantType::FORGE && target_res.blank?
#
    return sub_hash(hashed_var, end_prod, target_res = nil)
   end

  def special_prod(hashed_var)
    hashed_var[0] = hashed_var[0].transform_keys(&:to_sym)
    count = 0
    froms = define_formula("from")

    for i in 0..froms.length-1
      count = i if froms[i].key(hashed_var[0][:identificator]).present?
    end
#0

    tos = define_formula("to")
    target_res = tos[count][:identificator]

    end_prod = [{identificator: target_res, count: 0}]
    return sub_hash(hashed_var, end_prod)
  end

  def sub_hash(hashed_var, end_prod, target_res = nil)

    if target_res != nil
      form = define_formula("from", target_res)

    else
      target_res = end_prod[0][:identificator]
      form = define_formula("from", target_res)

    end

    done = false

    step = self.define_formula("to", target_res)[0][:count]

    max = define_formula("max_product", target_res)[0][:count]

    until done

      for i in 0..hashed_var.length-1
        form.each do |form_res|
           if hashed_var[i][:identificator] == form_res[:identificator]
            check = form_res[:count]
           else
            break
          end

          if (hashed_var[i][:count] - check < 0) or
             (end_prod[0][:count] + step > max) #
              done = true
              break
          else
              hashed_var[i][:count] -= check
              end_prod[0][:count] += step
          end
   end

         break if done
     end

       break if done
     end

     return end_prod
  end

  def forge_prod(hashed_var, target_res = nil)
    result = []
    self.define_formula("to").map{|res| res['identificator']}.each do |target_res|
      end_prod = [{identificator: target_res, count: 0}]
      result.push(sub_hash(hashed_var, end_prod, target_res))
    end

    return result
  end

  def add_hash(hashed_var)
      target_res = hashed_var[0][:identificator]

      raw_resources = []
      self.define_formula("from", target_res).each {|res| raw_resources.push({identificator: res[:identificator], count: 0})}
      if hashed_var[0][:count] >= self.define_formula("max_product", target_res)[0][:count]
        max = self.define_formula("max_product", target_res)[0][:count]
      else
        max = hashed_var[0][:count]
      end

      step = self.define_formula("to", target_res)[0][:count]

    ############ беспонтово
      for j in 0..(max-1)/step
        for i in 0..raw_resources.length-1
          a = (self.define_formula("from", target_res)[i][:count])*step

          raw_resources[i][:count] += a    #  if hashed_var[i][:identificator] == formula[i][:identificator]
        end
      end

    return raw_resources
  end

end




