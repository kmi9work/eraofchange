class CreateAlliances < ActiveRecord::Migration[7.0]
  def change
    create_table :alliances do |t|
      t.integer :country_id
      t.integer :partner_country_id
      t.integer :alliance_type_id

      t.timestamps
    end
  end
end

