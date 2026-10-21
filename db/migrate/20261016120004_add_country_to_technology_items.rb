class AddCountryToTechnologyItems < ActiveRecord::Migration[7.0]
  def change
    add_column :technology_items, :country_id, :integer, null: true
    add_index :technology_items, [:technology_id, :country_id], unique: true,
              name: 'index_technology_items_on_technology_and_country'
  end
end
