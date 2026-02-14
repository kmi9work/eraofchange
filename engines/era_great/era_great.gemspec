require_relative "lib/era_great/version"

Gem::Specification.new do |spec|
  spec.name        = "era_great"
  spec.version     = EraGreat::VERSION
  spec.authors     = ["Your Name"]
  spec.email       = ["your@email.com"]
  spec.summary     = "EraGreat game engine"
  spec.description = "Rails Engine for EraGreat game functionality"
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 7.0.6"
end

