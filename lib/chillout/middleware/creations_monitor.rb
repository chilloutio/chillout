module Chillout
  module Middleware
    class CreationsMonitor
      def initialize(app, client)
        @app = app
        @client = client
      end

      def call(env)
        dup._call(env)
      end

      def _call(env)
        status, headers, body = @app.call(env)
        return status, headers, body
      ensure
        if Thread.current[:creations]
          @client.logger.info "Non-empty creations container found"
          @client.enqueue(Thread.current[:creations])
          Thread.current[:creations] = nil
        end

        body.close if body && body.respond_to?(:close) && $!
      end
    end
  end
end
