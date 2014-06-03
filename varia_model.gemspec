# -*- encoding: utf-8 -*-
require File.expand_path('../lib/varia_model/version', __FILE__)

Gem::Specification.new do |spec|
  spec.authors       = ["Jamie Winsor"]
  spec.email         = ["jamie@vialstudios.com"]
  spec.description   = %q{A mixin to provide objects with magic attribute reading and writing}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/RiotGames/varia_model"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.name          = "varia_model"
  spec.require_paths = ["lib"]
  spec.version       = VariaModel::VERSION
  spec.required_ruby_version = ">= 1.9.1"

  spec.add_dependency "hashie", ">= 2.0.2", "< 3.0.0"
  spec.add_dependency "buff-extensions", "~> 1.0"

  spec.add_development_dependency "buff-ruby_engine", "~> 0.1"
  spec.add_development_dependency "thor", "~> 0.18.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fuubar"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-spork"
  spec.add_development_dependency "spork"
end
