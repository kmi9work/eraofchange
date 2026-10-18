class AddPartnerCountryToRelationItems < ActiveRecord::Migration[7.0]
  def change
    add_column :relation_items, :partner_country_id, :integer, null: true
    add_index :relation_items, [:country_id, :partner_country_id],
              name: 'index_relation_items_on_country_and_partner'
  end
end
