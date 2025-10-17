class CreateCaravans < ActiveRecord::Migration[7.0]
  def change
    create_table :caravans do |t|
      t.integer :guild_id  
      t.integer :country_id 
      t.json :incoming_resources #Заходящие В СТРАНУ
      t.bigint :incoming_gold, default: 0
      t.json :outcoming_resources #Выходящие ИЗ СТРАНЫ
      t.bigint :outcoming_gold, default: 0
      t.timestamps
    end
  end
end
