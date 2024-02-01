class CreateArmies < ActiveRecord::Migration[7.0]
  def change
    create_table :armies do |t|
      t.references :region, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :army_size, null: false, foreign_key: true

      t.timestamps
    end
  end
end
