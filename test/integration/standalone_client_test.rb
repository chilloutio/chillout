require 'test_helper'
require 'webmock/minitest'

class StandaloneClientTest < ChilloutTestCase

  def setup
    api_key = "xyz123"
    stub_api_request(api_key, "events")
    config  = Chillout::Config.new(api_key)
    config.ssl = false
    @client = Chillout::Client.new(config)
    @error  = build_error(NameError, "FooBar is not defined")
  end

  def test_request_headers_contain_content_type
    send_error
    assert_request_headers 'events', 'Content-Type' => 'application/vnd.chillout.v1+json'
  end

  def test_request_body_contains_exception_class
    send_error
    assert_equal "NameError", request_body["content"]["class"]
  end

  def test_request_body_contains_exception_message
    send_error
    assert_equal "FooBar is not defined", request_body["content"]["message"]
  end

  def test_request_body_contains_event_type
    send_error
    assert_equal "exception", request_body["event"]
  end

  def test_request_body_contains_shell_environment
    send_error
    assert_equal ENV.to_hash, request_body["content"]["shell_environment"]
  end

  def test_request_body_contains_notifier_name
    send_error
    assert_equal "Chillout", request_body["notifier"]["name"]
  end

  def test_request_body_contains_notifier_version
    send_error
    assert_equal Chillout::VERSION, request_body["notifier"]["version"]
  end

  def test_allows_to_send_exceptions
    exception = build_exception(ArgumentError, "wrong number of arguments")
    @client.send_exception(exception)
    assert_equal "ArgumentError", request_body["content"]["class"]
    assert_equal "wrong number of arguments", request_body["content"]["message"]
  end

  private
  def send_error
    @client.send_error(@error)
  end

  def request_body
    assert_request_body("events") { |body| return body }
  end

end
