require 'test_helper'
require 'chillout/event_data_builder'
require 'chillout/creations_container'

module Chillout
  class EventDataBuilderTest < ChilloutTestCase
    setup do
      @shell_env = { 'PATH' => '/bin:/usr/bin' }
      @api_key = "s3cr3t"

      @config = Config.new(@api_key)
      @config.platform = "rails"
      @config.environment = "development"
      @config.notifier_name = "chillout"
      @config.version = "0.1"
      @config.notifier_url = "http://github.com/arkency/chillout"

      @timestamp = Time.now.iso8601
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

    def assert_creations(key, value)
      assert_equal value, event_data[:content][:creations][key]
    end

    def assert_notifier(key, value)
      assert_equal value, event_data[:notifier][key]
    end
  end
end
