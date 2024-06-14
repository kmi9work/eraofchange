class CreateSettlementTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :settlement_types do |t|
      t.string :name
      t.json :params
      t.timestamps
    end
  end
end
