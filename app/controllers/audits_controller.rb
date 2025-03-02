class AuditsController < ApplicationController
  def index
    # if @current_user
    #   @audits = Audited::Audit.where("created_at > ?", @current_user.last_audit_show)
    #   @current_user.last_audit_show = Datetime.now
    #   @current_user.save
    # else
    # end
    @audits = Audited::Audit.last(20).reverse
  end
end
