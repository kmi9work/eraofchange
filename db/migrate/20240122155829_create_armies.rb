class CreateArmies < ActiveRecord::Migration[7.0]
  def change
    create_table :armies do |t|
      t.references :settlement, null: true, foreign_key: true
      t.integer :owner_id
      t.string :owner_type
      t.string :name
      t.boolean :hidden
      t.json :params
      t.timestamps
    end
  end
end
