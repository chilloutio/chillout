module Chillout
  class Dispatcher
    class SendCreationsFailed < StandardError
    end

    def initialize(filter, server_side)
      @filter      = filter
      @server_side = server_side
    end

    def send_creations(creations)
      @server_side.send_creations(creations)
    rescue HttpClient::NotSent
      raise SendCreationsFailed.new
    end

    def check_api_connection
      response = @server_side.send_check
      CheckResult.new(response)
    rescue HttpClient::NotReceived => e
      CheckResult.new(e)
    end
  end
end
