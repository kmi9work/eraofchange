module VassalsAndRobbers
  module Concerns
    module PlayerExtensions
      extend ActiveSupport::Concern

      included do
        # Сохраняем оригинальный метод income до его определения
        prepend InstanceMethods
      end

      module InstanceMethods
        def income(country = nil)
          target_country = country || self.country || Country.current
          # Вызываем оригинальный метод из родительского класса
          sum = super(target_country)

          # Доход от вассалов начисляется Казначею своего государства:
          # у каждого государства свой сюзерен и свой список вассалов
          if job_ids.include?(Job::KAZNACHEI)
            sum += PlayerExtensions.calculate_vassal_income(target_country)
          end

          sum
        end

        # Разбивка дохода показывает доход от вассалов отдельной строкой,
        # иначе сумма разбивки расходится с цифрой дохода Казначея (ТЗ № 2, § 7.2)
        def income_breakdown(country = nil)
          target_country = country || self.country || Country.current
          data = super(target_country)
          return data unless job_ids.include?(Job::KAZNACHEI)
          return data unless data.is_a?(Hash)

          vassal_income = PlayerExtensions.calculate_vassal_income(target_country)
          components = (data[:components] || {}).merge(vassal_income: vassal_income)

          data.merge(
            components: components,
            vassal_income: vassal_income,
            total: (data[:total] || 0) + vassal_income
          )
        end
      end

      # Доход от вассалов указанного сюзерена (по умолчанию — текущее государство)
      def self.calculate_vassal_income(sovereign = Country.current)
        total_income = 0
        return total_income if sovereign.nil?

        # Получаем настройки дохода от вассалов из GameParameter
        vassalage_settings = GameParameter.find_by(identificator: "vassalage_settings")
        return total_income unless vassalage_settings && vassalage_settings.params

        # Используем строковые ключи (Rails хранит JSON ключи как строки).
        # Формат «до перехода» — плоский хэш {вассал => доход} для «Руси»;
        # новый — {сюзерен => {вассал => доход}} (Д14.1)
        vassal_incomes = vassalage_settings.params['vassal_incomes'] || vassalage_settings.params[:vassal_incomes] || {}
        scoped_incomes = VassalsAndRobbers::VassalageSettings.incomes_for(vassal_incomes, sovereign)

        scoped_incomes.each do |vassal_country_id, income_amount|
          checklist = VassalsAndRobbers::Checklist.for_sovereign(sovereign).find_by(vassal_country_id: vassal_country_id)
          next unless checklist

          total_income += income_amount.to_i if checklist.established?(sovereign)
        end

        total_income
      end
    end
  end
end

