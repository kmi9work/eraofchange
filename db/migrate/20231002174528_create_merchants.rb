class CreateMerchants < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants do |t|
      t.string :name
      t.integer :plant_id
      t.integer :family_id
      t.integer :guild_id
      t.integer :player_id 
      t.timestamps
    end
  end
end
