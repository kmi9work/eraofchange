class CreateEconomicsubject < ActiveRecord::Migration[7.0]
  def change
    create_table :economicsubjects do |t|
      t.string :name
      t.string :category
      t.string :property
      t.timestamps
    end
  end
end
