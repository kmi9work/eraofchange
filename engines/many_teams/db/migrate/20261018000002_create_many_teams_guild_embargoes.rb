# Эмбарго государства на конкретную гильдию (п. 9). Строка = действующее эмбарго
# страны country_id на гильдию guild_id.
class CreateManyTeamsGuildEmbargoes < ActiveRecord::Migration[7.0]
  def change
    create_table :many_teams_guild_embargoes do |t|
      t.references :country, null: false, foreign_key: true, index: true
      t.references :guild, null: false, foreign_key: true, index: true
      t.integer :year
      t.string :comment
      t.timestamps
    end

    add_index :many_teams_guild_embargoes,
              %i[country_id guild_id],
              unique: true,
              name: "index_mt_guild_embargoes_on_country_and_guild"
  end
end
