require 'test_helper'
require 'sidekiq/testing'
require 'chillout/middleware/sidekiq'

module Chillout
  module Middleware
    class SidekiqTest < ChilloutTestCase

      def setup
        @client = mock("Client")
        @integration = Integrations::Sidekiq.new
        @integration.enable(@client, ::Sidekiq::Testing)
      end

      def teardown
        @integration.disable
      end

      class FakeJob
        MOCK_CREATIONS = Object.new.freeze
        include Sidekiq::Worker
        def perform
          Chillout.creations = MOCK_CREATIONS
        end
      end

      def test_enqueues_stats_and_clears_creations
        @client.expects(:enqueue).with(FakeJob::MOCK_CREATIONS)
        @client.expects(:enqueue).with do |measurement|
          SidekiqJobMeasurement === measurement &&
            measurement.success == "true" &&
            measurement.job_class == "Chillout::Middleware::SidekiqTest::FakeJob"
        end
        Sidekiq::Testing.inline! { FakeJob.perform_async }
        assert_nil Chillout.creations
      end

      class EmptyJob
        include Sidekiq::Worker
        def perform; end
      end

      def test_enqueues_stats_only_when_no_creations
        @client.expects(:enqueue).with do |measurement|
          SidekiqJobMeasurement === measurement
        end
        Sidekiq::Testing.inline! { EmptyJob.perform_async }
        assert_nil Chillout.creations
      end

      class ErrorJob
        Doh = Class.new(StandardError)
        include Sidekiq::Worker
        def perform
          raise Doh
        end
      end

      def test_enqueues_stats_even_on_failure
        @client.expects(:enqueue).with do |measurement|
          SidekiqJobMeasurement === measurement &&
            measurement.success == "false"
        end
        Sidekiq::Testing.inline! do
          assert_raises(ErrorJob::Doh) do
            ErrorJob.perform_async
          end
        end
        assert_nil Chillout.creations
      end

    end
  end
end