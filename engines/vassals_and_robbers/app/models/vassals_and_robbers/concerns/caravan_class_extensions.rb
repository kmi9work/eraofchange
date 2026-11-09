module VassalsAndRobbers
  module Concerns
    # «Поддержать экспорт»: казна получает 30% товарооборота (карточка), а не
    # 10%, как в ядре (`Caravan::GRAND_PRINCE_SHARE`).
    #
    # Переопределяем МЕТОД, а не константу: `GRAND_PRINCE_SHARE` — общая
    # константа ядра. Подключается только при активной игре vassals-and-robbers
    # (engine.rb), остальные игры считают по 10%.
    module CaravanClassExtensions
      TRADE_REVENUE_SHARE = 0.30

      def trade_revenue_share
        TRADE_REVENUE_SHARE
      end
    end
  end
end
