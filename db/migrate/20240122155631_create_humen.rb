class CreateHumen < ActiveRecord::Migration[7.0]
  def change
    create_table :humen do |t|
      t.string :name

      t.timestamps
    end
  end
end
