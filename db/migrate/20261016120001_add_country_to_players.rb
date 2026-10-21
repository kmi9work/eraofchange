class AddCountryToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :country_id, :integer, null: true
    add_index :players, :country_id
  end
end
