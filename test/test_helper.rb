require 'test/unit'
require 'mocha'
require 'contest'
require 'webmock/test_unit'
require 'rack/test'
require 'pathname'

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'chillout'

class ChilloutTestCase < Test::Unit::TestCase
  def refute(value, message=nil)
    assert !value, message || "Expected #{value.inspect} to be false."
  end

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

class AcceptanceTestCase < Test::Unit::TestCase

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
      http.post('/entities', "name=#{name}")
    end
  end

end

class TestApp

  def boot
    sample_app_name = ENV['SAMPLE_APP'] || 'rails_4_0_0'
    sample_app_root = Pathname.new(File.expand_path('../support', __FILE__)).join(sample_app_name)
    @pid = Process.spawn(
      {
        'BUNDLE_GEMFILE' => sample_app_root.join('Gemfile').to_s,
        'RAILS_ENV' => 'production'
      },
      Gem.ruby, sample_app_root.join('script/rails').to_s, 'server',
      :chdir => sample_app_root.to_s
    )
    wait_until_ready
  end

  def shutdown
    Process.kill('INT', @pid)
  rescue Errno::ESRCH
  ensure
    Process.wait(@pid) rescue nil
  end

  def wait_until_ready
    socket = nil
    30.times do
      begin
        socket = TCPSocket.open('127.0.0.1', 3000)
        break if socket
      rescue Errno::ECONNREFUSED
        sleep(1)
      end
    end
    if socket
      socket.close
    else
      raise RuntimeError.new('Could not start application')
    end
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
    5.times do
      begin
        return startups.pop(true)
      rescue ThreadError
        sleep(1)
      end
    end
    false
  end

  def has_one_creation_for_entity_resource
    5.times do
      begin
        return metrics.pop(true)
      rescue ThreadError
        sleep(1)
      end
    end
    false
  end

end

