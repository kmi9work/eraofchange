class PlayersJobsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :players, :jobs
  end
end
