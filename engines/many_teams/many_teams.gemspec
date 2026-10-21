require_relative "lib/many_teams/version"

Gem::Specification.new do |spec|
  spec.name        = "many_teams"
  spec.version     = ManyTeams::VERSION
  spec.authors     = ["Era"]
  spec.summary     = "Many teams game engine"
  spec.description = "Rails Engine for the many_teams game mode (several player countries, guild extraction and embargoes)"
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 7.0.6"
end
