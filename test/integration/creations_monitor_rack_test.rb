require 'test_helper'
require 'chillout/creations_container'

module Chillout
  class CreationsMonitorRackTest < ChilloutTestCase
    include Rack::Test::Methods

    def setup
      api_key = "xyz123"
      stub_api_request(api_key, "clients")
      stub_api_request(api_key, "metrics")
      @config = Chillout::Config.new(api_key)
      @client = Chillout::Client.new(@config, :logger => null_logger)
    end

    def app
      client = @client
      deepest_level = lambda do |env|
        Thread.current[:creations] = CreationsContainer.new
        2.times { Thread.current[:creations].increment!("User") }
        3.times { Thread.current[:creations].increment!("Cart") }
        [200, env, ['hello']]
      end
      Rack::Builder.new do
        use Middleware::CreationsMonitor, client
        run(deepest_level)
      end
    end

    def test_creations_values
      get "/"
      Thread.pass
      sleep 2
      assert_equal 2, request_body["measurements"].find{|m| m["series"] == "User" }.fetch("values").fetch("creations")
      assert_equal 3, request_body["measurements"].find{|m| m["series"] == "Cart" }.fetch("values").fetch("creations")
    end

    private
      def request_body
        assert_request_body("metrics") { |body| return body }
      end
  end
end
