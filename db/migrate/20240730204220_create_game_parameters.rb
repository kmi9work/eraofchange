class CreateGameParameters < ActiveRecord::Migration[7.0]
  def change
    create_table :game_parameters do |t|
      t.string :name
      t.string :identificator
      t.string :value
      t.json :params

      t.timestamps
    end
  end
end
