require 'test_helper'

module Chillout
  module Middleware
    class CreationsMonitorTest < ChilloutTestCase
      setup do
        @env = { 'HOST' => 'example.net' }
        @client = mock()
      end

      context "for call with model creation" do
        setup do
          @app = lambda do |env|
            Thread.current[:creations] = :creations
            [200, env, ['hello']]
          end
          @middleware = CreationsMonitor.new(@app, @client)
        end

        def test_behaves_like_rack_middleware
          @client.stubs(:send_creations)
          response = @middleware.call(@env)

          assert_equal [200, @env, ['hello']], response
        end

        def test_dispatch_creations_from_thread_current
          @client.expects(:send_creations).with(:creations)

          @middleware.call(@env)
        end
      end

      context "for call without model creation" do
        setup do
          @app = lambda do |env|
            [200, env, ['hello']]
          end
          @middleware = CreationsMonitor.new(@app, @client)
        end

        def test_behaves_like_rack_middleware
          response = @middleware.call(@env)

          assert_equal [200, @env, ['hello']], response
        end
      end
    end
  end
end
