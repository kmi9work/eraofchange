require "many_teams/version"
require "many_teams/engine"
require "many_teams/extensions"

module ManyTeams
  # Ключ активной игры этого движка: ACTIVE_GAME=many-teams
  ACTIVE_GAME = "many-teams".freeze

  # Ошибка предметной области движка: её сообщение показывается мастеру как есть
  class Error < StandardError; end

  def self.active?
    ENV["ACTIVE_GAME"].to_s == ACTIVE_GAME
  end

end
