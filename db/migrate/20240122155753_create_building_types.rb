class CreateBuildingTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :building_types do |t|
      t.string :name
      t.json :params
      t.string :icon
      t.timestamps
    end
  end
end
