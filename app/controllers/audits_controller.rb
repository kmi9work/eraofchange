class AuditsController < ApplicationController
  def index
    # if @current_user
    #   @audits = Audited::Audit.where("created_at > ?", @current_user.last_audit_show)
    #   @current_user.last_audit_show = Datetime.now
    #   @current_user.save
    # else
    # end
    
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
  end
end
