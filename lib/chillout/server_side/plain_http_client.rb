require 'net/https'

module Chillout
  class PlainHttpClient
    class NotCreated < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def code
        @response.code
      end
    end

    class CommunicationError < StandardError
      attr_reader :original_exception

      def initialize(exception)
        @original_exception = exception
      end
    end

    MEDIA_TYPE = "application/vnd.chillout.v1+json"

    def post(path, data)
      begin
        http = Net::HTTP.new("api.chillout.io", 443)
        http.use_ssl = true
        request_spec = Net::HTTP::Post.new(path)
        request_spec.body = MultiJson.dump(data)
        request_spec.content_type = MEDIA_TYPE
        response = http.start do
          http.request(request_spec)
        end
        raise NotCreated.new(response) if response.code != "201"
        MultiJson.load(response.body)
      rescue NotCreated
        raise
      rescue => e
        raise CommunicationError.new(e)
      end
    end
  end
end
