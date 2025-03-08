class CreateTechnologyItems < ActiveRecord::Migration[7.0]
  def change
    create_table :technology_items do |t|
      t.integer :value
      t.integer :technology_id
      t.integer :entity_id
      t.string :entity_type
      t.string :comment
      t.integer :year

      t.timestamps
    end
  end
end
