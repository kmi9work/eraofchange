module VassalsAndRobbers
  class ChecklistsController < ::ApplicationController
    # GET /vassals_and_robbers/checklists.json
    # Без параметров — чек-листы текущего сюзерена; ?country_id=<id> — указанного
    def index
      sovereign = requested_sovereign
      @checklists = VassalsAndRobbers::Checklist.for_sovereign(sovereign).includes(:vassal_country)

      result = @checklists.map do |checklist|
        validated_conditions = checklist.validate_all_conditions
        completed_count = validated_conditions.count { |c| c[:is_completed] }
        total_count = validated_conditions.count

        {
          id: checklist.id,
          sovereign_country: country_payload(checklist.sovereign),
          sovereign_country_id: checklist.sovereign&.id,
          vassal_country: country_payload(checklist.vassal_country),
          conditions: validated_conditions,
          completion_percentage: checklist.completion_percentage,
          completed_count: completed_count,
          total_count: total_count,
          vassalage_established: checklist.established?(sovereign),
          relations: checklist.vassal_country.relations(sovereign)
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
      sovereign = requested_sovereign || checklist.sovereign

      # Проверяем, что вассалитет еще не установлен
      if checklist.established?(sovereign)
        render json: { error: 'Вассалитет уже установлен' }, status: :unprocessable_entity
        return
      end

      # Устанавливаем флаг вассалитета по паре «сюзерен ↔ вассал»
      checklist.set_established(true, sovereign)

      render json: { success: true, message: "Вассалитет с #{checklist.vassal_country.name} установлен",
                     sovereign_country_id: sovereign&.id }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    # POST /vassals_and_robbers/checklists/:id/remove_vassalage.json
    def remove_vassalage
      checklist = VassalsAndRobbers::Checklist.find(params[:id])
      sovereign = requested_sovereign || checklist.sovereign

      unless checklist.established?(sovereign)
        render json: { error: 'Вассалитет не установлен' }, status: :unprocessable_entity
        return
      end

      # Убираем флаг вассалитета по паре
      checklist.set_established(false, sovereign)

      render json: { success: true, message: "Вассалитет с #{checklist.vassal_country.name} снят",
                     sovereign_country_id: sovereign&.id }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    # Сюзерен запроса: ?country_id=<id> или текущее государство
    def requested_sovereign
      return Country.current if params[:country_id].blank?

      Country.find_by(id: params[:country_id]) || Country.current
    end

    def country_payload(country)
      return nil if country.nil?

      {
        id: country.id,
        name: country.name,
        short_name: country.short_name,
        flag_image_name: country.flag_image_name
      }
    end
  end
end
