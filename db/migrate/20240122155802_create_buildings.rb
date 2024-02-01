class CreateBuildings < ActiveRecord::Migration[7.0]
  def change
    create_table :buildings do |t|
      t.string :comment
      t.json :params
      t.references :building_level, null: false, foreign_key: true
      t.references :settlement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
