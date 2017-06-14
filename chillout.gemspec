# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chillout/version'

Gem::Specification.new do |gem|
  gem.name          = "chillout"
  gem.version       = Chillout::VERSION
  gem.authors       = ["Michał Łomnicki", "Jan Filipowski", "Paweł Pacana"]
  gem.email         = ["michal.lomnicki@gmail.com", "jachuf@gmail.com", "pawel.pacana@gmail.com", "dev@arkency.com"]
  gem.description   = "Chillout gem tracks your ActiveRecord models statistics."
  gem.summary       = "Chillout.io Ruby client"
  gem.homepage      = "http://chillout.io/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'multi_json', '~> 1.4'

  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest",     "~> 5.1"
  gem.add_development_dependency "mocha",        "~> 0.14"
  gem.add_development_dependency "rack-test",    "~> 0.6"
  gem.add_development_dependency "rack",         ">= 1.6"
  gem.add_development_dependency "webmock",      "~> 2.3"
  gem.add_development_dependency "bbq-spawn",    "= 0.0.3"
  gem.add_development_dependency "childprocess", "= 0.3.6"
  gem.add_development_dependency "minitest-stub-const", "~> 0.6"
  gem.add_development_dependency "activejob", ">= 4.2"
end
