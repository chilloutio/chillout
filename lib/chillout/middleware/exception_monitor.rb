module Chillout
  module Middleware
    class ExceptionMonitor
      def initialize(app, client)
        @app    = app
        @client = client
      end

      def call(env)
        begin
          response = @app.call(env)
        rescue Exception => exception
          @client.dispatch_error(Chillout::Error.new(exception, env))
          raise exception
        end

        if env['rack.exception']
          @client.dispatch_error(Chillout::Error.new(env['rack.exception'], env))
        end

        response
      end
    end
  end
end
