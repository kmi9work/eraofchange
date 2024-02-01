class CreatePlantLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_levels do |t|
      t.integer :level
      t.integer :deposit
      t.integer :charge
      t.json :formula
      t.json :price
      t.integer :max_product

      t.timestamps
    end
  end
end
