# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'database_plumber/version'

Gem::Specification.new do |spec|
  spec.name          = "database_plumber"
  spec.version       = DatabasePlumber::VERSION
  spec.authors       = ["Barry Gordon"]
  spec.email         = ["barry@shopkeep.com"]
  spec.summary       = %q{Finds leaky ActiveRecord models in your specs.}
  spec.homepage      = "http://www.barrygordon.co.uk"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "rspec"
end
