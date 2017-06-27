module Chillout
  module Subscribers
    class ActionControllerNotifications

      class RequestMetric
        def initialize(event)
          @end      = event.end
          @duration = event.duration
          @payload  = event.payload.except(:headers)
        end

        def as_measurements()
          format = (payload[:format] || "all").to_s
          format = "all" if format == "*/*"

          [{
             series: "request",
             tags: {
               controller: payload[:controller],
               action:     payload[:action],
               format:     format,
               method:     payload[:method],
               status:     payload[:status],
             },
             timestamp: self.end.iso8601,
             values: {
               finished: 1,
               duration: duration,
               db:    payload[:db_runtime]   || 0,
               view:  payload[:view_runtime] || 0,
             },
           }]
        end

        attr_reader :end, :duration, :payload
      end

      def enable(client)
        name = "process_action.action_controller"
        ActiveSupport::Notifications.subscribe(name) do |*args|
          event  = ActiveSupport::Notifications::Event.new(*args)
          metric = RequestMetric.new(event)
          client.enqueue(metric)
        end
      end

    end
  end
end