require 'chillout/server_side/plain_http_client'

module Chillout
  class Registration
    class NotRegisteredByLimit < StandardError; end
    class NotRegisteredByInvalidData < StandardError; end
    class NotRegisteredByAccident < StandardError; end
    class NotRegisteredByCommunicationError < StandardError; end

    def initialize(http_client=PlainHttpClient.new)
      @http_client = http_client
    end

    def register(name, emails)
      data = {
        :name => name,
        :emails => emails
      }
      response_body = @http_client.post("/projects", data)
      response_body["api_key"].strip
    rescue PlainHttpClient::NotCreated => e
      if e.code == "403"
        raise NotRegisteredByLimit.new
      elsif e.code == "400"
        raise NotRegisteredByInvalidData.new
      else
        raise NotRegisteredByAccident.new
      end
    rescue PlainHttpClient::CommunicationError => e
      raise NotRegisteredByCommunicationError.new
    end
  end
end
