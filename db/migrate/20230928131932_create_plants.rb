class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :name
      t.string :category
      t.integer :price
      t.string :level
      t.string :location
      t.timestamps
    end
  end
end
