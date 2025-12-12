class RenameCaravanFieldsToImportExport < ActiveRecord::Migration[7.0]
  def change
    rename_column :caravans, :resources_from_pl, :resources_export
    rename_column :caravans, :resources_to_pl, :resources_import
    rename_column :caravans, :gold_from_pl, :gold_export
    rename_column :caravans, :gold_to_pl, :gold_import
  end
end









