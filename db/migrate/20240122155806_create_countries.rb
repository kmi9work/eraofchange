class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :title
      t.json :params

      t.timestamps
    end
  end
end
