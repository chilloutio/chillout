require 'test/unit'
require 'mocha'
require 'contest'
require 'webmock/minitest'
require 'rack/test'

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'chillout'

class ChilloutTestCase < Test::Unit::TestCase

  def build_exception(klass = Exception, message = "Test Exception")
    raise klass.new(message)
  rescue Exception => exception
    exception
  end

  def build_error(klass, message = "Test Error", environment = {})
    exception = build_exception(klass, message)
    Chillout::Error.new(exception, environment)
  end

  def stub_api_request(api_key, resource_name)
    @_api_key = api_key
    stub_request(:post, api_url(resource_name))
  end

  def assert_request_body(resource_name)
    assert_requested(:post, api_url(resource_name)) do |request|
      yield JSON.parse(request.body)
    end
  end

  def assert_request_headers(resource_name, headers = {})
    assert_requested(:post, api_url(resource_name), headers: headers)
  end

  def api_url(resource_name)
    raise "API KEY not set" unless @_api_key
    "http://#{@_api_key}:#{@_api_key}@api.chillout.io/#{resource_name}"
  end

end

class ChilloutTestException < Exception; end
