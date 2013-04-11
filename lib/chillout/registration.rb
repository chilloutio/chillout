require 'chillout/server_side/plain_http_client'

module Chillout
  class Registration
    def initialize(http_client=PlainHttpClient.new)
      @http_client = http_client
    end

    def register(name, emails)
      data = {
        :name => name,
        :emails => emails
      }
      response_body = @http_client.post("/projects", data)
      response_body.strip
    end
  end
end
