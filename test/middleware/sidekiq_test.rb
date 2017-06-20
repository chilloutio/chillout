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

      def test_enqueues_and_clears_creations
        @client.expects(:enqueue).with(FakeJob::MOCK_CREATIONS)
        Sidekiq::Testing.inline! { FakeJob.perform_async }
        assert_nil Chillout.creations
      end

      class EmptyJob
        include Sidekiq::Worker
        def perform; end
      end

      def test_does_nothing_when_no_creations
        Sidekiq::Testing.inline! { EmptyJob.perform_async }
        assert_nil Chillout.creations
      end

    end
  end
end