# Подтверждённый на странице «Дашборд» набор государств игроков (п. 7).
# Именно на их территории гильдии могут строить предприятия.
class CreateManyTeamsPlayerCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :many_teams_player_countries do |t|
      t.references :country, null: false, foreign_key: true, index: { unique: true }
      t.integer :year
      t.timestamps
    end
  end
end
