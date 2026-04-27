class CreateAllianceTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :alliance_types do |t|
      t.string :name
      t.integer :min_relations_level

      t.timestamps
    end
  end
end

