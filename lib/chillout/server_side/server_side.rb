require 'time'

module Chillout
  class ServerSide

    def initialize(config, http_client)
      @http_client = http_client
      @config = config
    end

    def send_measurements(measurements)
      send_metric(
        :measurements => measurements.map(&:as_measurements).flatten,
        :notifier => {
          name:    @config.notifier_name,
          version: @config.version,
          url:     @config.notifier_url,
        }
      )
    end

    def send_metric(data)
      @http_client.post('/metrics', data)
    end

    def send_check
      @http_client.get('/check')
    end

    def send_startup_message
      @http_client.post('/clients', {
        :message => 'worker started'
      })
    end

  end
end