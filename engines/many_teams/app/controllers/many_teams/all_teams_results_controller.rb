module ManyTeams
  # Окно «Результаты всех команд» («Служебное → Вывод На Экран»): общий зачёт по
  # всем командам (экономика и политика) и личный зачёт (знать и гильдии).
  # Только чтение — данные для табло считает `ManyTeams::AllTeamsResults`.
  class AllTeamsResultsController < BaseController
    # GET /many_teams/all_teams_results
    def index
      render json: ManyTeams::AllTeamsResults.new.as_json
    end
  end
end
