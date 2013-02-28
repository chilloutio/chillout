require 'time'
require 'chillout/event_data_builder'

module Chillout
  class ServerSide

    def initialize(event_data_builder, http_client)
      @http_client = http_client
      @event_data_builder = event_data_builder
    end

    def send_error(error)
      event_data = @event_data_builder.build_from_error(error, timestamp)
      send_event(event_data)
    end

    def send_event(data)
      @http_client.post('/events', data)
    end

    def send_creations(creations_container)
      event_data = @event_data_builder.build_from_creations_container(creations_container, timestamp)
      send_metric(event_data)
    end

    def send_metric(data)
      @http_client.post('/metrics', data)
    end

    private
      def timestamp
        Time.now.iso8601
      end
  end
end
