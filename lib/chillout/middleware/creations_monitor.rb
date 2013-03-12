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
          @client.enqueue(Thread.current[:creations])
          Thread.current[:creations] = nil
        end
        response
      end
    end
  end
end
