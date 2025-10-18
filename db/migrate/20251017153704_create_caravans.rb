class CreateCaravans < ActiveRecord::Migration[7.0]
  def change
    create_table :caravans do |t|
      t.integer :guild_id  
      t.integer :country_id 
      t.json    :resources_from_pl #Заходящие В СТРАНУ
      t.json    :resources_to_pl #Выходящие ИЗ СТРАНЫ
      t.integer :trade_turnover #player_got
      t.timestamps
    end
  end
end
