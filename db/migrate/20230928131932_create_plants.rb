class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :comments
      t.integer :player_id
      t.integer :guild_id
      t.integer :plant_level_id
      t.integer :plant_category_id
      t.integer :plant_type_id
      t.integer :plant_place_id
      t.integer :economic_subject_id
      t.string :economic_subject_type
      t.integer :settlement_id
      t.integer :recource_id
      t.timestamps
    end
  end
end
