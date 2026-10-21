module VassalsAndRobbers
  # Настройки вассальных доходов государства.
  #
  # Поддерживаются два формата params['vassal_incomes']:
  #   1) плоский {вассал => доход} — формат «до перехода», относился к «Руси»;
  #   2) вложенный {сюзерен => {вассал => доход}} — после перехода на несколько
  #      государств (Д14.1): у каждого сюзерена свои вассалы и свои суммы.
  # Читатели не должны знать о формате — только этот модуль.
  module VassalageSettings
    module_function

    # Вложенный (новый) формат: значения — хэши
    def nested_format?(vassal_incomes)
      vassal_incomes.is_a?(Hash) && vassal_incomes.values.any? { |value| value.is_a?(Hash) }
    end

    # Доходы вассалов указанного сюзерена (по умолчанию — текущее государство)
    def incomes_for(vassal_incomes, sovereign = Country.current)
      stored = vassal_incomes.is_a?(Hash) ? vassal_incomes : {}
      return {} if sovereign.nil?

      if nested_format?(stored)
        scoped = stored[sovereign.id.to_s] || stored[sovereign.id.to_s.to_sym]
        scoped.is_a?(Hash) ? scoped : {}
      else
        # Плоский формат — доходы «Руси»; для других государств настроек ещё нет
        sovereign.id.to_i == Country::RUS ? stored : {}
      end
    end

    # Записать доходы вассалов сюзерена, сохранив настройки остальных государств.
    # Плоский (легаси) формат переносится в ключ «Руси» — ничего не теряется.
    def store_incomes(vassal_incomes, sovereign, incomes)
      stored = vassal_incomes.is_a?(Hash) ? vassal_incomes.dup : {}
      return stored if sovereign.nil?

      if !nested_format?(stored)
        legacy = stored
        stored = legacy.present? ? { Country::RUS.to_s => legacy } : {}
      end

      stored[sovereign.id.to_s] = incomes || {}
      stored
    end
  end
end
