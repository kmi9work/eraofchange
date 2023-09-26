class CreateEconomicSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :economic_subjects do |t|
      t.string :name
      t.string :category
      t.string :money
      t.timestamps
    end
  end
end
