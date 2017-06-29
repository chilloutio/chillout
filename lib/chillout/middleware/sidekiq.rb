module Chillout
  module Middleware

    class SidekiqCreationsMonitor
      def initialize(options)
        @client = options.fetch(:client)
      end

      def call(_worker, _job, _queue)
        yield
      ensure
        if creations = Chillout.creations
          Chillout.creations = nil
          @client.enqueue(creations)
        end
      end
    end

  end
end