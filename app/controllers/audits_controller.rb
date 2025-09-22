class AuditsController < ApplicationController
  def index
    # Загружаем аудиты с разными ассоциациями для разных типов auditable
    @audits = Audited::Audit.includes(
      auditable: [
        :job, 
        :political_action_type, 
        :player, 
        :entity, 
        :settlement, 
        :building_level,
        building_level: :building_type
      ]
    ).last(50).reverse
    
    # Загружаем просмотренные события для текущего пользователя
    if current_user
      @viewed_audit_ids = current_user.viewed_audits.pluck(:audit_id)
    else
      @viewed_audit_ids = []
    end
  end
  
  def mark_as_viewed
    if current_user
      audit_id = params[:audit_id]
      
      if audit_id
        # Отмечаем конкретное событие как просмотренное
        audit = Audited::Audit.find_by(id: audit_id)
        if audit
          # Создаем или обновляем запись о просмотре конкретного события
          viewed_audit = current_user.viewed_audits.find_or_initialize_by(audit_id: audit_id)
          viewed_audit.viewed_at = Time.current
          viewed_audit.save
        end
      else
        # Если ID не передан, обновляем время последнего просмотра (для совместимости)
        current_user.update(last_audit_show: Time.current)
      end
      
      render json: { status: 'success' }
    else
      render json: { status: 'error', message: 'User not found' }, status: 401
    end
  end

  def mark_all_as_viewed
    if current_user
      # Получаем все аудиты, которые еще не просмотрены
      unviewed_audits = Audited::Audit.where.not(id: current_user.viewed_audits.pluck(:audit_id))
      
      # Создаем записи для всех непросмотренных событий
      viewed_audits_data = unviewed_audits.map do |audit|
        {
          user_id: current_user.id,
          audit_id: audit.id,
          viewed_at: Time.current,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
      
      # Массовая вставка для производительности
      ViewedAudit.insert_all(viewed_audits_data) if viewed_audits_data.any?
      
      render json: { 
        status: 'success', 
        marked_count: viewed_audits_data.length 
      }
    else
      render json: { status: 'error', message: 'User not found' }, status: 401
    end
  end
end
