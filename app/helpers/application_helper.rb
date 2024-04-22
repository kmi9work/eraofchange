module ApplicationHelper
  def render_cost(cost)
    cost_str = cost.map{|res_id, value| "#{value} #{Resourse.find_by_identificator(res_id)&.name}"}.join(", ")
    "Игрок должен внести за армии: #{cost_str}"
  end
end
