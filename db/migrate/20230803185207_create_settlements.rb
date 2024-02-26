class CreateSettlements < ActiveRecord::Migration[7.0]
  def change
    create_table :settlements do |t|
      t.string :name
      t.integer :settlement_type_id
      t.integer :region_id
      t.integer :player_id
      t.integer :plant_place_id
      t.integer :building_id
      t.timestamps
    end
  end
end
