source 'https://rubygems.org'

gem "bbq-spawn", git: 'https://github.com/drugpl/bbq-spawn.git'

# Specify your gem's dependencies in chillout.gemspec
gemspec

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2')
  gem "rack", "1.6"
  gem "activejob", "= 4.2.8"
  gem "sidekiq", "~> 4.2"
end