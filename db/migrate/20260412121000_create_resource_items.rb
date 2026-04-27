class CreateResourceItems < ActiveRecord::Migration[7.0]
  def change
    create_table :resource_items do |t|
      t.integer :economic_subject_id
      t.string  :economic_subject_type
      t.string  :identificator, null: false
      t.integer :count, default: 0, null: false

      t.timestamps
    end

    add_index :resource_items, [:economic_subject_type, :economic_subject_id],
              name: "index_resource_items_on_economic_subject"
    add_index :resource_items, [:economic_subject_type, :economic_subject_id, :identificator],
              name: "index_resource_items_on_subject_and_identificator", unique: true
  end
end
