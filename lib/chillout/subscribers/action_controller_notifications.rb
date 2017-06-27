module Chillout
  module Subscribers
    class ActionControllerNotifications

      class RequestMetric
        def initialize(event)
          @event = event
        end

        def as_measurements()
          format = (event.payload[:format] || "all").to_s
          format = "all" if format == "*/*"

          [{
             series: "request",
             tags: {
               controller: event.payload[:controller],
               action:     event.payload[:action],
               format:     format,
               method:     event.payload[:method],
               status:     event.payload[:status],
             },
             timestamp: event.end.iso8601,
             values: {
               finished: 1,
               duration: event.duration,
               db:    event.payload[:db_runtime]   || 0,
               view:  event.payload[:view_runtime] || 0,
             },
           }]
        end

        private

        attr_reader :event
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