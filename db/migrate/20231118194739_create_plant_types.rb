class CreatePlantTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_types do |t|
      t.string :name
      t.integer :plant_category_id
      t.integer :fossil_type_id
      t.string :icon
                  
      t.timestamps
    end
  end
end
