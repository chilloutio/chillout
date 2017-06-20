require 'bundler/gem_tasks'
require 'rake/testtask'


SAMPLE_APPS = Dir.glob(File.join(File.dirname(__FILE__), 'test/support/rails_*'))

desc 'Install test dependencies.'
task :bundle do
  sample_apps = if sample_app = ENV['SAMPLE_APP']
    [ File.join(File.dirname(__FILE__), "test/support/#{sample_app}") ]
  else
    SAMPLE_APPS
  end
  sample_apps.each do |path|
    Bundler.clean_system "bundle install --quiet --gemfile #{File.join(path, 'Gemfile')}"
  end
end

desc 'Run chillout tests.'
Rake::TestTask.new(:test) do |t|
  t.libs    = %w(lib test)
  t.pattern = 'test/**/*_test.rb'
end

task :default => :test
