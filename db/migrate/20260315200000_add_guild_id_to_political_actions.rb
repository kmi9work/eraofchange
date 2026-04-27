class AddGuildIdToPoliticalActions < ActiveRecord::Migration[7.0]
  def change
    add_column :political_actions, :guild_id, :integer
    add_index :political_actions, :guild_id
  end
end
