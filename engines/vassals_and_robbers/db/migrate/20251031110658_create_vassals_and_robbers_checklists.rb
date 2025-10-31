class CreateVassalsAndRobbersChecklists < ActiveRecord::Migration[7.0]
  def change
    create_table :vassals_and_robbers_checklists do |t|
      t.integer :vassal_country_id, null: false
      t.jsonb :conditions, default: {}
      
      t.timestamps
    end
    
    add_index :vassals_and_robbers_checklists, :vassal_country_id
    add_foreign_key :vassals_and_robbers_checklists, :countries, column: :vassal_country_id
  end
end
