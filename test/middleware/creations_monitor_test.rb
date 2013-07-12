require 'test_helper'

module Chillout
  module Middleware
    class CreationsMonitorTest < ChilloutTestCase
      def setup
        @env = { 'HOST' => 'example.net' }
        @logger = stub(:info => "")
        @client = stub(:logger => @logger)
      end

      def call_with_model_creation
        @app = lambda do |env|
          Thread.current[:creations] = :creations
          [200, env, ['hello']]
        end
        @middleware = CreationsMonitor.new(@app, @client)
      end

      def test_behaves_like_rack_middleware
        call_with_model_creation
        @client.stubs(:enqueue)
        response = @middleware.call(@env)
        assert_equal [200, @env, ['hello']], response
      end

      def test_clients_queue_receive_creations
        call_with_model_creation
        @client.expects(:enqueue).with(:creations)

        @middleware.call(@env)
      end

      def call_without_model_creation
        @app = lambda do |env|
          [200, env, ['hello']]
        end
        @middleware = CreationsMonitor.new(@app, @client)
      end

      def test_behaves_like_rack_middleware
        call_without_model_creation
        response = @middleware.call(@env)

        assert_equal [200, @env, ['hello']], response
      end
    end
  end
end
