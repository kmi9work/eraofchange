class AddYearToAudits < ActiveRecord::Migration[7.0]
  def change
    add_column :audits, :year, :integer
    add_index :audits, :year
  end
end
