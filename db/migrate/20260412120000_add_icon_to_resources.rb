class AddIconToResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :icon, :string
  end
end
