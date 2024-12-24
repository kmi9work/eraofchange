class CreatePlantLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_levels do |t|
      t.integer :level
      t.integer :deposit
      t.json :formulas
      t.json :price
      t.integer :plant_type_id

      t.timestamps
    end
  end
end
