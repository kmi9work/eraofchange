class CreatePoliticalActionTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :political_action_types do |t|
      t.string :icon
      t.string :name
      t.string :action
      t.integer :job_id
      t.json :params
      t.text :description
      t.string :cost
      t.string :probability
      t.text :success
      t.text :failure
      t.timestamps
    end
  end
end
