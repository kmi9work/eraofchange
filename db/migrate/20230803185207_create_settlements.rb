class CreateSettlements < ActiveRecord::Migration[7.0]
  def change
    create_table :settlements do |t|
      t.string :name
      t.integer :settlement_category_id #Даша + seeds
      t.timestamps
    end
  end
end
