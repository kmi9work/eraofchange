class CreateTroops < ActiveRecord::Migration[7.0]
  def change
    create_table :troops do |t|
      t.boolean :is_hired
      t.references :troop_type, null: true, foreign_key: true
      t.references :army, null: true, foreign_key: true

      t.timestamps
    end
  end
end
