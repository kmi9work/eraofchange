class CreatePlantPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_places do |t|
      t.string :title
      t.integer :plant_category_id
      t.integer :region_id
      t.timestamps
    end
  end
end
