class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :comments
      t.integer :player_id
      t.integer :plant_level_id
      t.integer :plant_place_id
      t.integer :economic_subject_id
      t.string :economic_subject_type
      
      t.timestamps
    end
  end
end
