module Chillout
  module Middleware
    class CreationsMonitor
      def initialize(app, client)
        @app = app
        @client = client
      end

      def call(env)
        response = @app.call(env)
        if Thread.current[:creations]
          @client.send_creations(Thread.current[:creations])
          Thread.current[:creations] = nil
        end
        response
      end
    end
  end
end
