# Разрешение гильдии добывать на территории конкретного государства (п. 4).
# Строка — явное переопределение умолчания: «добыча открыта в стране гильдии,
# закрыта в остальных». Нет строки — действует умолчание.
class CreateManyTeamsGuildExtractionPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :many_teams_guild_extraction_permissions do |t|
      t.references :guild, null: false, foreign_key: true, index: true
      t.references :country, null: false, foreign_key: true, index: true
      t.boolean :allowed, null: false, default: false
      t.integer :year
      t.string :comment
      t.timestamps
    end

    add_index :many_teams_guild_extraction_permissions,
              %i[guild_id country_id],
              unique: true,
              name: "index_mt_extraction_permissions_on_guild_and_country"
  end
end
