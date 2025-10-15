class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.json :buying_resources
      t.json :selling_resources
      t.json :params
      t.timestamps
    end
  end
end
