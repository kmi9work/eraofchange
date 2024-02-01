class CreatePlantPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_places do |t|
      t.string :title
      t.string :plant_place_type

      t.timestamps
    end
  end
end
