module VassalsAndRobbers
  class ChecklistsController < ::ApplicationController
    # GET /vassals_and_robbers/checklists.json
    def index
      @checklists = VassalsAndRobbers::Checklist.all.includes(:vassal_country)
      
      result = @checklists.map do |checklist|
        vassal_param_key = "vassal_#{checklist.vassal_country_id}_established"
        is_vassalage_established = checklist.params && checklist.params[vassal_param_key] == true
        
        validated_conditions = checklist.validate_all_conditions
        completed_count = validated_conditions.count { |c| c[:is_completed] }
        total_count = validated_conditions.count
        
        {
          id: checklist.id,
          vassal_country: {
            id: checklist.vassal_country.id,
            name: checklist.vassal_country.name,
            short_name: checklist.vassal_country.short_name,
            flag_image_name: checklist.vassal_country.flag_image_name
          },
          conditions: validated_conditions,
          completion_percentage: checklist.completion_percentage,
          completed_count: completed_count,
          total_count: total_count,
          vassalage_established: is_vassalage_established,
          relations: checklist.vassal_country.relations
        }
      end
      
      # Сортируем по названию страны
      result.sort_by! { |item| item[:vassal_country][:name] }
      
      render json: result
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # POST /vassals_and_robbers/checklists/:id/establish_vassalage.json
    def establish_vassalage
      checklist = VassalsAndRobbers::Checklist.find(params[:id])
      
      # Проверяем, что вассалитет еще не установлен
      vassal_param_key = "vassal_#{checklist.vassal_country_id}_established"
      if checklist.params && checklist.params[vassal_param_key] == true
        render json: { error: 'Вассалитет уже установлен' }, status: :unprocessable_entity
        return
      end

      # Устанавливаем флаг вассалитета
      checklist.params ||= {}
      checklist.params[vassal_param_key] = true
      checklist.save!

      render json: { success: true, message: "Вассалитет с #{checklist.vassal_country.name} установлен" }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # POST /vassals_and_robbers/checklists/:id/remove_vassalage.json
    def remove_vassalage
      checklist = VassalsAndRobbers::Checklist.find(params[:id])
      
      # Проверяем, что вассалитет установлен
      vassal_param_key = "vassal_#{checklist.vassal_country_id}_established"
      unless checklist.params && checklist.params[vassal_param_key] == true
        render json: { error: 'Вассалитет не установлен' }, status: :unprocessable_entity
        return
      end

      # Убираем флаг вассалитета
      checklist.params[vassal_param_key] = false
      checklist.save!

      render json: { success: true, message: "Вассалитет с #{checklist.vassal_country.name} снят" }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end
end

