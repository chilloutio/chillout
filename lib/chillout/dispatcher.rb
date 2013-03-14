module Chillout
  class Dispatcher
    class SendCreationsFailed < StandardError
    end

    def initialize(filter, server_side)
      @filter      = filter
      @server_side = server_side
    end

    def dispatch_error(error)
      if @filter.deliver_error?(error)
        send_error(error)
      end
    end

    def send_error(error)
      @server_side.send_error(error)
    rescue HttpClient::NotSent
    end

    def send_creations(creations)
      @server_side.send_creations(creations)
    rescue HttpClient::NotSent
      raise SendCreationsFailed.new
    end
  end
end
