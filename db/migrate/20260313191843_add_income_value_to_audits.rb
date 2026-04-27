class AddIncomeValueToAudits < ActiveRecord::Migration[7.0]
  def change
    add_column :audits, :income_value, :integer, default: nil
    add_index :audits, :income_value
  end
end
