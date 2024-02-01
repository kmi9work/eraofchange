class CreateFossilTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :fossil_types do |t|
      t.string :title

      t.timestamps
    end
  end
end
