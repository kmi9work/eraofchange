module VassalsAndRobbers
  module Concerns
    # «Поддержать экспорт» в этой игре поднимает цену продажи на 50% (карточка),
    # а не на 20%, как в ядре (`Resource::TARIFF`).
    #
    # Переопределяем МЕТОД, а не константу: `Resource::TARIFF` — общая константа
    # ядра, и её правка молча меняет artel/many_teams. Хук подключается только
    # при активной игре vassals-and-robbers (engine.rb), поэтому остальные игры
    # продолжают считать по 20%.
    module ResourceClassExtensions
      SELL_PRICE_TARIFF = 1.50

      def sell_price_tariff
        SELL_PRICE_TARIFF
      end
    end
  end
end
