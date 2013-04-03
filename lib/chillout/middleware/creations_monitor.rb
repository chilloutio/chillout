module Chillout
  module Middleware
    class CreationsMonitor
      def initialize(app, client)
        @app = app
        @client = client
      end

      def call(env)
        response = @app.call(env)
      ensure
        if Thread.current[:creations]
          @client.logger.info "Non-empty creations container found"
          @client.enqueue(Thread.current[:creations])
          Thread.current[:creations] = nil
        end
        response
      end
    end
  end
end
