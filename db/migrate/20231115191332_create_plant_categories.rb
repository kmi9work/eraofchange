class CreatePlantCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :plant_categories do |t|
      t.string :name
      t.boolean :is_extractive
      t.string :icon
      t.timestamps
    end
  end
end
