class CreateIdeologistTechnologies < ActiveRecord::Migration[7.0]
  def change
    create_table :ideologist_technologies do |t|
      t.string :name
      t.json :requirements
      t.json :params
      t.references :ideologist_type, foreign_key: true

      t.timestamps
    end
  end
end
