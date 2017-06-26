module Chillout
  class Dispatcher
    class SendCreationsFailed < StandardError
    end

    def initialize(server_side)
      @server_side = server_side
    end

    def send_measurements(measurements)
      @server_side.send_measurements(measurements)
    rescue HttpClient::NotSent
      raise SendCreationsFailed.new
    end

    def check_api_connection
      response = @server_side.send_check
      CheckResult.new(response)
    rescue HttpClient::NotReceived => e
      CheckResult.new(e)
    end

    def send_startup_message
      @server_side.send_startup_message
    rescue HttpClient::NotReceived
    end
  end
end
