class CreatePoliticalActions < ActiveRecord::Migration[7.0]
  def change
    create_table :political_actions do |t|
      t.integer :year
      t.integer :success
      t.json :params
      t.references :player, foreign_key: true
      t.references :job, foreign_key: true
      t.references :political_action_type, foreign_key: true

      t.timestamps
    end
  end
end
