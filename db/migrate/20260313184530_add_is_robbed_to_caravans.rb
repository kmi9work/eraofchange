class AddIsRobbedToCaravans < ActiveRecord::Migration[7.0]
  def change
    add_column :caravans, :is_robbed, :boolean, default: false, null: false
    add_index :caravans, :is_robbed
  end
end
