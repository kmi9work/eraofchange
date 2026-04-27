class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.string :name
      t.integer :country_id
      t.string :identificator
      t.json :params
      t.timestamps
    end
  end
end
