class CreateCredits < ActiveRecord::Migration[7.0]
  def change
    create_table :credits do |t|
      t.integer :sum
      t.integer :deposit
      t.float :procent
      t.integer :start_year
      t.integer :duration

      t.timestamps
    end
  end
end
