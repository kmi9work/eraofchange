class AddDeletedAtToArmies < ActiveRecord::Migration[7.0]
  def change
    add_column :armies, :deleted_at, :datetime
  end
end
