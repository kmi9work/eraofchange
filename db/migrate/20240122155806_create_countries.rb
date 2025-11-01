class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :short_name
      t.string :flag_image_name # Название файла изображения флага (латиница, без пробелов)
      t.json :params
      t.timestamps
    end
  end
end
