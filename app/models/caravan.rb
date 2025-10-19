class Caravan < ApplicationRecord
  belongs_to :guild, optional: true
  belongs_to :country

   # {"country_id"=>2, "incoming"=>[{"identificator"=>"horses", "name"=>"Лошади", "count"=>111,
   #  "current_sell_price"=>58}], "outcoming"=>[], "purchase_cost"=>0, 
   # "sale_income"=>6438, "gold_paid"=>0, "controller"=>"caravans", 
   # "action"=>"register_caravan", "caravan"=>{"country_id"=>2}
  
  def self.register_caravan(params)
    caravan = Caravan.create!(
      country_id:        params[:country_id],
      resources_from_pl: params[:incoming],
      resources_to_pl:   params[:outcoming],
      gold_from_pl:      params[:purchase_cost],
      gold_to_pl:        params[:sale_income] 
    )
    
    { success: true, caravan: caravan }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: e.message }
  rescue => e
    { success: false, error: e.message }
  end  


end
