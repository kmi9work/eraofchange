class CreateTroops < ActiveRecord::Migration[7.0]
  def change
    create_table :troops do |t|
      t.references :troop_type, null: false, foreign_key: true
      t.boolean :is_hired
      t.references :army, null: false, foreign_key: true

      t.timestamps
    end
  end
end
