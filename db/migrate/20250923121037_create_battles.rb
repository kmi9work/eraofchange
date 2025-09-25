class CreateBattles < ActiveRecord::Migration[7.0]
  def change
    create_table :battles do |t|
      t.references :attacker_army, null: true, foreign_key: { to_table: :armies }
      t.references :defender_army, null: true, foreign_key: { to_table: :armies }
      t.references :winner_army, null: true, foreign_key: { to_table: :armies }
      t.string :attacker_owner_name
      t.string :defender_owner_name
      t.string :winner_owner_name
      t.string :attacker_army_name
      t.string :defender_army_name
      t.string :winner_army_name
      t.integer :damage
      t.integer :year
      t.text :comment

      t.timestamps
    end
  end
end
