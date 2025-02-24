class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions do |t|
      t.string :title
      t.integer :country_id
      t.integer :player_id
      t.json :params

      t.timestamps
    end
  end
end
