class CreatePoliticalActionTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :political_action_types do |t|
      t.string :title
      t.json :action
      t.json :params

      t.timestamps
    end
  end
end
