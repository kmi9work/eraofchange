class CreateCaravans < ActiveRecord::Migration[7.0]
  def change
    create_table :caravans do |t|
      t.integer :guild_id  
      t.integer :country_id
      t.integer :year
      t.json    :resources_from_pl 
      t.json    :resources_to_pl 
      t.integer :gold_from_pl
      t.integer :gold_to_pl
      t.boolean :via_vyatka, default: false
      t.timestamps
    end
  end
end
