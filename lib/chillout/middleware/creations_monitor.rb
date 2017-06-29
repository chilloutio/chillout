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
        if creations = Chillout.creations
          @client.logger.debug "Non-empty creations container found"
          @client.enqueue(creations)
          Chillout.creations = nil
        end

        body.close if body && body.respond_to?(:close) && $!
      end
    end
  end
end
