require 'test_helper'

module Chillout
  module Middleware
    class ExceptionMonitorTest < ChilloutTestCase

      class DummyError < StandardError; end

      def test_behaves_like_rack_middleware
        env        = { 'HOST' => 'example.net' }
        app        = lambda { |env| [200, env, ['hello']] }
        middleware = ExceptionMonitor.new(app, mock)

        response = middleware.call(env)

        assert_equal [200, env, ['hello']], response
      end

      def test_exception_is_raised
        exception = build_exception(DummyError)
        env = { 'HOST' => 'example.net' }
        app = lambda do |env|
          raise exception
        end
        dispatcher = mock("Dispatcher")
        dispatcher.expects(:dispatch_error).with do |error|
          error.exception == exception && error.environment == env
        end

        middleware = ExceptionMonitor.new(app, dispatcher)
        assert_raises DummyError do
          middleware.call(env)
        end
      end

      def test_exception_is_found_in_rack_environment
        exception = build_exception(DummyError)
        env = { 'HOST' => 'example.net' }
        app = lambda do |env|
          env['rack.exception'] = exception
          [200, env, ['hello']]
        end
        dispatcher = mock("Dispatcher")
        dispatcher.expects(:dispatch_error).with do |error|
          error.exception == exception && error.environment == env
        end

        middleware = ExceptionMonitor.new(app, dispatcher)
        middleware.call(env)
      end

    end
  end
end
