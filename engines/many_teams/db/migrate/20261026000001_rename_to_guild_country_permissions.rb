# Переименование «разрешения на добычу» в «разрешение гильдии в государстве».
#
# По правилам игры запрет один: он одинаково закрывает и строительство
# предприятий, и работу уже построенных (п. 0). Категория предприятия
# (добывающее/перерабатывающее) роли не играет, поэтому в названиях больше нет
# слова «добыча».
#
# Данные не переносятся: таблица та же, меняется только имя; значение `allowed`
# (=false/true) читается ровно как раньше.
class RenameToGuildCountryPermissions < ActiveRecord::Migration[7.0]
  OLD_TABLE = :many_teams_guild_extraction_permissions
  NEW_TABLE = :many_teams_guild_country_permissions

  INDEX_RENAMES = {
    "many_teams_guild_extraction_permissions_pkey" => "many_teams_guild_country_permissions_pkey",
    "index_many_teams_guild_extraction_permissions_on_guild_id" =>
      "index_many_teams_guild_country_permissions_on_guild_id",
    "index_many_teams_guild_extraction_permissions_on_country_id" =>
      "index_many_teams_guild_country_permissions_on_country_id",
    "index_mt_extraction_permissions_on_guild_and_country" =>
      "index_mt_guild_country_permissions_on_guild_and_country"
  }.freeze

  # Действие Казначея переименовано; строка каталога уже существует в базах,
  # поэтому обновляем её, а не создаём новую (сид 0_political_action_types.rb
  # делает то же самое через find_or_initialize_by по колонке action).
  ACTION_RENAMES = { "set_guild_extraction" => "set_guild_permission" }.freeze

  def up
    rename_table OLD_TABLE, NEW_TABLE
    INDEX_RENAMES.each do |old_name, new_name|
      next unless index_name_exists?(NEW_TABLE, old_name)

      execute "ALTER INDEX #{quote_table_name(old_name)} RENAME TO #{quote_table_name(new_name)}"
    end

    ACTION_RENAMES.each do |old_action, new_action|
      execute <<~SQL.squish
        UPDATE political_action_types SET action = #{quote(new_action)}
        WHERE action = #{quote(old_action)}
      SQL
    end
  end

  def down
    ACTION_RENAMES.each do |old_action, new_action|
      execute <<~SQL.squish
        UPDATE political_action_types SET action = #{quote(old_action)}
        WHERE action = #{quote(new_action)}
      SQL
    end

    INDEX_RENAMES.each do |old_name, new_name|
      next unless index_name_exists?(NEW_TABLE, new_name)

      execute "ALTER INDEX #{quote_table_name(new_name)} RENAME TO #{quote_table_name(old_name)}"
    end

    rename_table NEW_TABLE, OLD_TABLE
  end
end
