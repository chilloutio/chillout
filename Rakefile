require 'bundler/gem_tasks'
require 'rake/testtask'


SAMPLE_APPS = Dir.glob(File.join(File.dirname(__FILE__), 'test/support/rails_*'))

desc 'Install test dependencies.'
task :bundle do
  SAMPLE_APPS.each do |path|
    Bundler.clean_system "bundle install --quiet --gemfile #{File.join(path, 'Gemfile')}"
  end
end

desc 'Run chillout unit tests.'
Rake::TestTask.new(:unit) do |t|
  t.libs    = %w(lib test)
  t.pattern = 'test/*_test.rb'
end

desc 'Run chillout integration tests.'
Rake::TestTask.new(:integration) do |t|
  t.libs    = %w(lib test)
  t.pattern = 'test/integration/*_test.rb'
end

desc 'Run chillout acceptance tests.'
Rake::TestTask.new(:acceptance) do |t|
  t.libs    = %w(lib test)
  t.pattern = 'test/acceptance/*_test.rb'
end

task :test => %w(unit integration acceptance)
task :default => :test
