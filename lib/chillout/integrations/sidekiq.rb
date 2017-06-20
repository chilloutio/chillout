module Chillout
  module Integrations

    class Sidekiq
      def available?
        defined?(::Sidekiq) && ::Sidekiq.server?
      end

      def enable(client, a_module = ::Sidekiq)
        require 'chillout/middleware/sidekiq'
        @module = a_module
        @module.server_middleware.add Middleware::SidekiqCreationsMonitor,
          client: client
      end

      def disable
        @module.server_middleware.clear
      end
    end

  end
end