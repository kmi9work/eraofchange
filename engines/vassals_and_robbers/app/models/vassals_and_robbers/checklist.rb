module VassalsAndRobbers
  class Checklist < ApplicationRecord
    self.table_name = 'vassals_and_robbers_checklists'
    
    belongs_to :vassal_country, class_name: 'Country', foreign_key: 'vassal_country_id'
    
    validates :vassal_country_id, presence: true, uniqueness: true
    validates :conditions, presence: true
    
    # Метод для получения всех условий чек-листа
    def get_conditions
      conditions.dig('conditions') || []
    end
    
    # Метод для проверки всех условий
    def validate_all_conditions
      validator = VassalsAndRobbers::ChecklistValidator.new
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
      return 0 if results.empty?
      
      completed_count = results.count { |r| r[:is_completed] }
      (completed_count.to_f / results.count * 100).round
    end
    
    # Метод класса для получения списка ID стран, у которых установлен вассалитет
    def self.vassal_country_ids
      all.select do |checklist|
        vassal_param_key = "vassal_#{checklist.vassal_country_id}_established"
        checklist.params && checklist.params[vassal_param_key] == true
      end.map(&:vassal_country_id)
    end
  end
end