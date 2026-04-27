class CreateBuildings < ActiveRecord::Migration[7.0]
  def change
    create_table :buildings do |t|
      t.string :comment
      t.json :params,  default: {"paid" => []}
      t.references :building_level, foreign_key: true
      t.references :settlement, foreign_key: true

      t.timestamps
    end
  end
end
