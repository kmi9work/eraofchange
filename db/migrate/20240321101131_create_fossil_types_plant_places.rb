class CreateFossilTypesPlantPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :fossil_types_plant_places do |t|
      t.references :fossil_type
      t.references :plant_place      

      t.timestamps
    end
  end
end
