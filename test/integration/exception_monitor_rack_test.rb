require 'test_helper'

class ExceptionMonitorRackTest < ChilloutTestCase
  include Rack::Test::Methods

  def setup
    api_key = "xyz123"
    stub_api_request(api_key, "events")
    @config = Chillout::Config.new(api_key)
    @config.ssl = false
    @client = Chillout::Client.new(@config)
  end

  def app
    client = @client # Only local variable can be passed to the block below
    Rack::Builder.new do
      use Chillout::Middleware::ExceptionMonitor, client
      run(lambda { |env| raise ChilloutTestException.new("Something went wrong") })
    end
  end

  def test_exception_class
    trigger_error
    assert_equal "ChilloutTestException", request_body["content"]["class"]
  end

  def test_exception_message
    trigger_error
    assert_equal "Something went wrong", request_body["content"]["message"]
  end

  def test_rack_environment
    trigger_error
    assert_request_body "events" do |body|
      assert_equal last_request.env.keys, body["content"]["rack_environment"].keys
    end
  end

  private
  def trigger_error
    begin
      get "/"
    rescue ChilloutTestException
    end
  end

  def request_body
    assert_request_body("events"){ |body| return body }
  end

end
