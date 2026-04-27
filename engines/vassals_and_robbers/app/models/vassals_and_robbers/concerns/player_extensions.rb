module VassalsAndRobbers
  module Concerns
    module PlayerExtensions
      extend ActiveSupport::Concern

      included do
        # Сохраняем оригинальный метод income до его определения
        prepend InstanceMethods
      end

      module InstanceMethods
        def income
          # Вызываем оригинальный метод из родительского класса
          sum = super
          
          # Добавляем доход от вассалов для Казначея
          if job_ids.include?(Job::KAZNACHEI)
            sum += PlayerExtensions.calculate_vassal_income
          end
          
          sum
        end
      end

      # Метод класса для расчета дохода от вассалов
      def self.calculate_vassal_income
        total_income = 0
        
        # Получаем настройки дохода от вассалов из GameParameter
        vassalage_settings = GameParameter.find_by(identificator: "vassalage_settings")
        return total_income unless vassalage_settings && vassalage_settings.params
        
        # Используем строковые ключи (Rails хранит JSON ключи как строки)
        vassal_incomes = vassalage_settings.params['vassal_incomes'] || vassalage_settings.params[:vassal_incomes] || {}
        
        vassal_incomes.each do |vassal_country_id, income_amount|
          # Проверяем, установлен ли вассалитет
          checklist = VassalsAndRobbers::Checklist.find_by(vassal_country_id: vassal_country_id)
          next unless checklist
          
          # Проверяем флаг установленного вассалитета
          vassal_param_key = "vassal_#{vassal_country_id}_established"
          is_established = checklist.params && checklist.params[vassal_param_key] == true
          
          if is_established
            total_income += income_amount.to_i
          end
        end
        
        total_income
      end
    end
  end
end

