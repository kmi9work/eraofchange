class CreatePlantLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_levels do |t|
      t.integer :level
      t.integer :deposit
      t.integer :charge
      t.json :formula
      t.json :price
      t.json :max_product
      t.integer :plant_type_id

      t.timestamps
    end
  end
end
