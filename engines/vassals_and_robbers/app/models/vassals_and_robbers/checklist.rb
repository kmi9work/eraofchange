module VassalsAndRobbers
  class Checklist < ApplicationRecord
    self.table_name = 'vassals_and_robbers_checklists'

    # Сюзерен чек-листа. Колонка nullable: записи, созданные до перехода на несколько
    # государств, сюзерена не имеют — для них им считается «Русь» (легаси, Д14.1).
    belongs_to :sovereign_country, class_name: 'Country', foreign_key: 'sovereign_country_id', optional: true
    belongs_to :vassal_country, class_name: 'Country', foreign_key: 'vassal_country_id'

    # Одно государство может быть вассалом только одного сюзерена: уникальность по паре
    validates :vassal_country_id, presence: true, uniqueness: { scope: :sovereign_country_id }
    validates :conditions, presence: true

    # Чек-листы сюзерена: свои строки плюс (для «Руси») легаси-строки без сюзерена
    scope :for_sovereign, ->(country) do
      next all if country.nil?

      if country.id.to_i == Country::RUS
        where(sovereign_country_id: [country.id, nil])
      else
        where(sovereign_country_id: country.id)
      end
    end

    # Сюзерен чек-листа: явная колонка, иначе (легаси) — «Русь»
    def sovereign
      sovereign_country || Country.rus_country
    end

    # Ключ легаси-флага вассалитета (до перехода на пары «сюзерен ↔ вассал»)
    def legacy_flag_key
      "vassal_#{vassal_country_id}_established"
    end

    # Установлен ли вассалитет по паре (сюзерен по умолчанию — сюзерен чек-листа)
    def established?(sovereign_country_arg = nil)
      sovereign_id = (sovereign_country_arg || sovereign)&.id
      return false if sovereign_id.nil?

      by_pair = params&.dig('vassalage', sovereign_id.to_s, vassal_country_id.to_s)
      return by_pair if by_pair == true || by_pair == false

      # Легаси-ключ относился к паре с «Русью»
      return false unless sovereign_id.to_i == Country::RUS

      params&.[](legacy_flag_key) == true
    end

    # Отметить вассалитет по паре; легаси-ключ синхронизируем для «Руси»,
    # чтобы старые читатели не разошлись с новым форматом
    def set_established(value, sovereign_country_arg = nil)
      sovereign_id = (sovereign_country_arg || sovereign)&.id
      return false if sovereign_id.nil?

      current = params || {}
      vassalage = current['vassalage']
      vassalage = {} unless vassalage.is_a?(Hash)
      pair = vassalage[sovereign_id.to_s]
      pair = {} unless pair.is_a?(Hash)

      pair[vassal_country_id.to_s] = value
      vassalage[sovereign_id.to_s] = pair
      current['vassalage'] = vassalage
      current[legacy_flag_key] = value if sovereign_id.to_i == Country::RUS

      self.params = current
      save
    end

    # Метод для получения всех условий чек-листа
    def get_conditions
      conditions.dig('conditions') || []
    end

    # Метод для проверки всех условий
    def validate_all_conditions
      validator = VassalsAndRobbers::ChecklistValidator.new(sovereign)
      validation_results = []

      get_conditions.each do |condition|
        result = validator.validate_condition(condition)
        validation_results << {
          type: condition['type'],
          description: condition['description'] || condition['alliance_type'] || '',
          requirement: condition['requirement'] || condition['alliance_type'],
          current_value: result[:current_value],
          is_completed: result[:success]
        }
      end

      validation_results
    end

    # Метод для расчета процента выполнения
    def completion_percentage
      results = validate_all_conditions
      if results.empty?
        return 100 if established?(sovereign)
        return 0
      end

      completed_count = results.count { |r| r[:is_completed] }
      (completed_count.to_f / results.count * 100).round
    end

    # Список ID стран-вассалов указанного сюзерена (по умолчанию — текущего государства)
    def self.vassal_country_ids(sovereign = Country.current)
      for_sovereign(sovereign).select { |checklist| checklist.established?(sovereign) }.map(&:vassal_country_id)
    end
  end
end
