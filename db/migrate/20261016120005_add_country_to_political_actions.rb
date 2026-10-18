class AddCountryToPoliticalActions < ActiveRecord::Migration[7.0]
  def change
    add_column :political_actions, :country_id, :integer, null: true
    add_index :political_actions, :country_id
  end
end
