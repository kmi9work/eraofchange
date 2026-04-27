# EXAMPLE: Это шаблонный файл для создания своего Engine
require_relative "lib/artel/version"

Gem::Specification.new do |spec|
  spec.name        = "artel"
  spec.version     = Artel::VERSION
  spec.authors     = ["Your Name"]
  spec.email       = ["your@email.com"]
  spec.summary     = "Artel game engine"
  spec.description = "Rails Engine for Artel game functionality"
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 7.0.6"
end


