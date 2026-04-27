# EXAMPLE: Это шаблонный файл для создания своего Engine
# Конфигурация активной игры
Rails.application.configure do
  config.active_game = ENV.fetch('ACTIVE_GAME', 'base_game')
end

# Хелпер для проверки активной игры
module GameHelper
  def game_active?(game_name)
    Rails.configuration.active_game == game_name.to_s
  end

  def vassals_and_robbers_active?
    game_active?('vassals_and_robbers')
  end
end

ActiveSupport.on_load(:action_controller) do
  include GameHelper
end

ActiveSupport.on_load(:action_view) do
  include GameHelper
end

