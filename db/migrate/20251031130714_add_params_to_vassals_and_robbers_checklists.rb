class AddParamsToVassalsAndRobbersChecklists < ActiveRecord::Migration[7.0]
  def change
    add_column :vassals_and_robbers_checklists, :params, :jsonb, default: {}
  end
end
