class CreateBuildingPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :building_places do |t|
      t.integer :category
      t.json :params
      t.timestamps
    end
  end
end
