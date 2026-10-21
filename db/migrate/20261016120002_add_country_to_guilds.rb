class AddCountryToGuilds < ActiveRecord::Migration[7.0]
  def change
    add_column :guilds, :country_id, :integer, null: true
    add_index :guilds, :country_id
  end
end
