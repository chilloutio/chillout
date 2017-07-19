source 'https://rubygems.org'

gem "bbq-spawn", git: 'https://github.com/drugpl/bbq-spawn.git'

# Specify your gem's dependencies in chillout.gemspec
gemspec

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2')
  gem "rack", "1.6"
  gem "activejob", "= 4.2.8"
  gem "sidekiq", ENV['SIDEKIQ_VERSION'] || "~> 4.2"
else
  gem "sidekiq", ENV['SIDEKIQ_VERSION'] || ">= 5"
end

if ENV['TEST_AR']
  gem "activerecord", ENV['SAMPLE_APP'].
    split("_").
    select{|t| Integer(t) rescue nil }.
    take(3).
    join(".")
end