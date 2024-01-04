class CreatePlantTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_types do |t|
      t.string :name
      t.integer :plant_category_id
      t.integer :plant_yield
      t.integer :resources_id
      t.integer :price
      t.timestamps
    end
  end
end
