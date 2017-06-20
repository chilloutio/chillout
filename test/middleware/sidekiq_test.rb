require 'test_helper'
require 'sidekiq/testing'
require 'chillout/middleware/sidekiq'

module Chillout
  module Middleware
    class SidekiqTest < ChilloutTestCase

      def setup
        @client = mock("Client")
        Sidekiq::Testing.server_middleware do |chain|
          chain.add Chillout::Middleware::SidekiqCreationsMonitor,
                    client: @client
        end
      end

      def teardown
        Sidekiq::Testing.server_middleware.clear
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
        Sidekiq::Testing.inline! do
          FakeJob.perform_async
        end
        assert_nil Chillout.creations
      end

      class EmptyJob
        include Sidekiq::Worker
        def perform
        end
      end

      def test_does_nothing_when_no_creations
        Sidekiq::Testing.inline! do
          EmptyJob.perform_async
        end
        assert_nil Chillout.creations
      end

    end
  end
end