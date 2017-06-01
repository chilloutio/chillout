require 'minitest/autorun'
require 'mocha/setup'
require 'webmock/minitest'
require 'rack/test'
require 'pathname'
require 'bbq/spawn'

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'chillout'

class ChilloutTestCase < MiniTest::Unit::TestCase
  def assert_includes(collection, object, message=nil)
    assert collection.include?(object), message || "#{collection.inspect} expected to include #{object.inspect}."
  end

  def stub_api_request(api_key, resource_name)
    @_api_key = api_key
    stub_request(:post, api_url(resource_name))
  end

  def assert_request_body(resource_name)
    assert_requested(:post, api_url(resource_name)) do |request|
      yield MultiJson.load(request.body)
    end
  end

  def assert_request_headers(resource_name, headers = {})
    assert_requested(:post, api_url(resource_name), :headers => headers)
  end

  def api_url(resource_name)
    raise "API KEY not set" unless @_api_key
    "https://#{@_api_key}:#{@_api_key}@api.chillout.io/#{resource_name}"
  end

  def null_logger
    Logger.new('/dev/null')
  end

  def assert_successful_exit(pid)
    _, status = Process.wait2(pid)
    assert_equal 0, status.exitstatus
  end
end

class AcceptanceTestCase < MiniTest::Unit::TestCase

  def setup
    WebMock.disable!
  end

  def teardown
    WebMock.enable!
  end

end

require 'net/http'

class TestUser

  def create_entity(name)
    Net::HTTP.start('127.0.0.1', 3000) do |http|
      response = http.post('/entities', "entity[name]=#{name}")
    end
  end

end

class TestApp

  def boot
    sample_app_name = ENV['SAMPLE_APP'] || 'rails_4_0_0'
    sample_app_root = Pathname.new(File.expand_path('../support', __FILE__)).join(sample_app_name)
    command         = [Gem.ruby, sample_app_root.join('script/rails').to_s, 'server'].join(' ')
    @executor = Bbq::Spawn::Executor.new(command) do |process|
      process.cwd = sample_app_root.to_s
      process.environment['BUNDLE_GEMFILE'] = sample_app_root.join('Gemfile').to_s
      process.environment['RAILS_ENV']      = 'production'
    end
    @executor = Bbq::Spawn::CoordinatedExecutor.new(@executor, :url => 'http://127.0.0.1:3000')
    @executor.start
    @executor.join
  end

  def shutdown
    @executor.stop
  end

end

class TestEndpoint

  attr_reader :metrics, :startups

  def initialize
    @metrics  = Queue.new
    @startups = Queue.new
  end

  def listen
    Thread.new do
      Rack::Server.start(
        :app  => self,
        :Host => 'localhost',
        :Port => 8080
      )
    end
  end

  def call(env)
    payload = MultiJson.load(env['rack.input'].read) rescue {}

    case env['PATH_INFO']
    when /clients/
      startups << payload
    when /metrics/
      metrics  << payload
    end

    [200, {'Content-Type' => 'text/plain'}, ['OK']]
  end

  def has_received_information_about_startup
    10.times do
      begin
        return startups.pop(true)
      rescue ThreadError
        sleep(1)
      end
    end
    false
  end

  def has_one_creation_for_entity_resource
    10.times do
      begin
        return metrics.pop(true)
      rescue ThreadError
        sleep(1)
      end
    end
    false
  end

end

