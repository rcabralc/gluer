# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gluer/version'

Gem::Specification.new do |spec|
  spec.name          = "gluer"
  spec.version       = Gluer::VERSION
  spec.authors       = ["rcabralc"]
  spec.email         = ["rcabralc@gmail.com"]
  spec.description   = %q{Configuration reloader}
  spec.summary       = %q{Reloads configuration code in a per-file basis}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rake"
end
