class CreateBuildingLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :building_levels do |t|
      t.integer :level
      t.string :name
      t.json :price
      t.json :params
      t.references :building_type, foreign_key: true

      t.timestamps
    end
  end
end
