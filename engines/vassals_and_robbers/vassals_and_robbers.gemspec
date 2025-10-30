# EXAMPLE: Это шаблонный файл для создания своего Engine
require_relative "lib/vassals_and_robbers/version"

Gem::Specification.new do |spec|
  spec.name        = "vassals_and_robbers"
  spec.version     = VassalsAndRobbers::VERSION
  spec.authors     = ["Your Name"]
  spec.email       = ["your@email.com"]
  spec.summary     = "Vassals and Robbers game engine"
  spec.description = "Rails Engine for Vassals and Robbers game functionality"
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 7.0.6"
end

