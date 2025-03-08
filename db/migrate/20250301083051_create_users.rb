class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :job
      t.datetime :last_audit_show
      t.timestamps
    end
  end
end
