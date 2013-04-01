# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chillout/version'

Gem::Specification.new do |gem|
  gem.name          = "chillout"
  gem.version       = Chillout::VERSION
  gem.authors       = ["Michał Łomnicki", "Jan Filipowski"]
  gem.email         = ["michal.lomnicki@gmail.com", "jachuf@gmail.com", "dev@arkency.com"]
  gem.description   = "Chillout.io Ruby client"
  gem.summary       = "Chillout.io Ruby client"
  gem.homepage      = "http://chillout.io/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "json", "~> 1.7.0"
  gem.add_development_dependency "minitest", "~>3.2.0"
  gem.add_development_dependency "rake",  "~> 0.9.2"
  gem.add_development_dependency "mocha", "0.12.8"
  gem.add_development_dependency "contest", "~> 0.1.3"
  gem.add_development_dependency "rack-test", "~> 0.6.2"
  gem.add_development_dependency "webmock", "~> 1.8.11"
end
