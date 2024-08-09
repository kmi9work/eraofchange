class CreateSettlements < ActiveRecord::Migration[7.0]
  def change
    create_table :settlements do |t|
      t.string :name
      t.integer :settlement_type_id
      t.integer :region_id
      t.integer :player_id
      t.json :params
      t.timestamps
    end
  end
end
