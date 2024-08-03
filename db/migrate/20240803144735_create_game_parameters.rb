class CreateGameParameters < ActiveRecord::Migration[7.0]
  def change
    create_table :game_parameters do |t|
      t.string :title
      t.string :identificator
      t.boolean :value
      t.json :params
      t.timestamps
    end
  end
end
