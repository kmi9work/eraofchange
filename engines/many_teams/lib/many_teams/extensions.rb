module ManyTeams
  # Установка расширений ядра. Подключается из ManyTeams::Engine#to_prepare,
  # поэтому повторяется при перезагрузке кода в dev — все операции идемпотентны
  # (`Module#prepend` одного и того же модуля повторно ничего не делает).
  module Extensions
    CONCERNS_GLOB = "app/models/many_teams/concerns/*.rb".freeze

    def self.install!
      return false unless ManyTeams.active?

      load_concerns

      prepend_to(::Resource, ManyTeams::Concerns::ResourceClassExtensions, singleton: true)
      prepend_to(::Plant, ManyTeams::Concerns::PlantExtensions)
      prepend_to(::Guild, ManyTeams::Concerns::GuildExtensions)
      prepend_to(::Country, ManyTeams::Concerns::CountryExtensions)
      prepend_to(::PoliticalAction, ManyTeams::Concerns::PoliticalActionExtensions)
      prepend_to(::PoliticalActionType, ManyTeams::Concerns::PoliticalActionTypeExtensions)
      prepend_to(::PlantPlacesController, ManyTeams::Concerns::PlantPlacesControllerExtensions)
      prepend_to(::Caravan, ManyTeams::Concerns::CaravanClassExtensions, singleton: true)

      true
    rescue StandardError => e
      Rails.logger.error("[ManyTeams] Не удалось подключить расширения: #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.first(10).join("\n"))
      false
    end

    def self.load_concerns
      Dir.glob(ManyTeams::Engine.root.join(CONCERNS_GLOB)).sort.each do |file|
        require_dependency file.to_s
      end
    end

    def self.prepend_to(klass, mod, singleton: false)
      return if mod.nil?
      return unless defined?(klass) && klass.is_a?(Module)

      target = singleton ? klass.singleton_class : klass
      target.prepend(mod) unless target.ancestors.include?(mod)
    end
  end
end
