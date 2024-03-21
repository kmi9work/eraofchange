class CreatePlayerTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :player_types do |t|
      t.string :title
      
      t.timestamps
    end
  end
end
