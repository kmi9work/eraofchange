class CreatePublicOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :public_order_items do |t|
      t.integer :value
      t.integer :region_id
      t.integer :entity_id
      t.string :entity_type
      t.string :comment
      t.integer :year

      t.timestamps
    end
  end
end
