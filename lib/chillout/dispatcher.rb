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
  end
end
