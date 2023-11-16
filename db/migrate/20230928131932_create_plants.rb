class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :name
      t.integer :plant_category_id
      t.integer :price
      t.integer :level
      t.integer :economic_subject_id
      t.string :economic_subject_type
      t.integer :settlement_id
      t.timestamps
    end
  end
end
