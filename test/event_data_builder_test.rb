require 'test_helper'
require 'chillout/event_data_builder'
require 'chillout/creations_container'

module Chillout
  class EventDataBuilderTest < ChilloutTestCase
    setup do
      @shell_env = { 'PATH' => '/bin:/usr/bin' }
      @api_key = "s3cr3t"

      @config = Config.new(@api_key)
      @config.shell_environment = @shell_env
      @config.platform = "rails"
      @config.environment = "development"
      @config.notifier_name = "chillout"
      @config.version = "0.1"
      @config.notifier_url = "http://github.com/arkency/chillout"

      @timestamp = Time.now.iso8601
    end

    context "build from error" do
      setup do
        @event_data_builder = EventDataBuilder.new(@config)

        @controller = mock("Controller")
        @controller.stubs(:controller_name).returns("UsersController")
        @controller.stubs(:action_name).returns("index")

        @current_user = mock("User")
        @current_user.stubs(:id).returns(123)
        @current_user.stubs(:email).returns("john@example.com")
        @current_user.stubs(:full_name).returns("john doe")

        @exception = build_exception(NameError, "FooBar does not exists")
        @env = {
          'HTTP_USER_AGENT' => 'Mozilla/4.0',
          'action_controller.instance' => @controller,
          'current_user' => @current_user
        }
        @error = Chillout::Error.new(@exception, @env)
        @event_data = @event_data_builder.build_from_error(@error, @timestamp)
      end

      def test_event_type
        assert_param :event, 'exception'
      end

      def test_timestamp
        assert_param :timestamp, @timestamp
      end

      def test_exception_class
        assert_content :class, 'NameError'
      end

      def test_exception_message
        assert_content :message, 'FooBar does not exists'
      end

      def test_backtrace
        assert_content :backtrace, @exception.backtrace
      end

      def test_file
        assert_content :file, @error.file
      end

      def test_environment
        assert_content :environment, "development"
      end

      def test_platform
        assert_context :platform, "rails"
      end

      def test_controller
        assert_context :controller, "UsersController"
      end

      def test_action
        assert_context :controller, "UsersController"
      end

      def test_current_user_id
        assert_current_user :id, 123
      end

      def test_current_user_email
        assert_current_user :email, "john@example.com"
      end

      def test_current_user_full_name
        assert_current_user :full_name, "john doe"
      end

      def test_rack_environment
        expected_value = Hash[@env.collect { |k,v| [k, v.to_s] }]
        assert_content :rack_environment, expected_value
      end

      def test_shell_environment
        assert_content :shell_environment, @shell_env
      end

      def test_notifier_name
        assert_notifier :name, "chillout"
      end

      def test_notifier_version
        assert_notifier :version, "0.1"
      end

      def test_notifier_url
        assert_notifier :url, "http://github.com/arkency/chillout"
      end
    end

    context "build from creations container" do
      setup do
        @creations_container = CreationsContainer.new
        5.times { @creations_container.increment!("User") }
        3.times { @creations_container.increment!("Cart") }
        8.times { @creations_container.increment!("CartItem") }

        @event_data_builder = EventDataBuilder.new(@config)
        @event_data = @event_data_builder.build_from_creations_container(@creations_container, @timestamp)
      end

      def test_metric_type
        assert_param :metric, "creations"
      end

      def test_timestamp
        assert_param :timestamp, @timestamp
      end

      def test_each_counter
        assert_creations :User, 5
        assert_creations :Cart, 3
        assert_creations :CartItem, 8
      end

      def test_environment
        assert_content :environment, "development"
      end

      def test_notifier_name
        assert_notifier :name, "chillout"
      end

      def test_notifier_version
        assert_notifier :version, "0.1"
      end

      def test_notifier_url
        assert_notifier :url, "http://github.com/arkency/chillout"
      end
    end

    private
    def event_data
      @event_data
    end

    def assert_param(key, value)
      assert_equal value, event_data[key]
    end

    def assert_content(key, value)
      assert_equal value, event_data[:content][key]
    end

    def assert_context(key, value)
      assert_equal value, event_data[:content][:context][key]
    end

    def assert_creations(key, value)
      assert_equal value, event_data[:content][:creations][key]
    end

    def assert_current_user(key, value)
      assert_equal value, event_data[:content][:context][:current_user][key]
    end

    def assert_notifier(key, value)
      assert_equal value, event_data[:notifier][key]
    end
  end
end
