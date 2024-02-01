class CreateArmySizes < ActiveRecord::Migration[7.0]
  def change
    create_table :army_sizes do |t|
      t.integer :level
      t.json :params

      t.timestamps
    end
  end
end
