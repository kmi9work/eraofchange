class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :family_id
      t.integer :merchant_id
      t.timestamps
    end
  end
end