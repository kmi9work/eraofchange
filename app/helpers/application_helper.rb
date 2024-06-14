module ApplicationHelper
  def render_cost(cost)
    cost.map{|res_id, value| "#{value} #{Resourse.find_by_identificator(res_id)&.name}"}.join(", ")
  end
end
