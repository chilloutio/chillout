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

    attr_reader :host, :port, :ssl

    def initialize
      @host = if ENV['CHILLOUT_CLIENT_HOST']
        ENV['CHILLOUT_CLIENT_HOST']
      else
        "api.chillout.io"
      end
      @port = if ENV['CHILLOUT_CLIENT_PORT']
        ENV['CHILLOUT_CLIENT_PORT'].to_i
      else
        443
      end
      @ssl = if ENV['CHILLOUT_CLIENT_SSL']
        ENV['CHILLOUT_CLIENT_SSL'] == 'true'
      else
        true
      end
    end

    MEDIA_TYPE = "application/vnd.chillout.v1+json"

    def post(path, data)
      begin
        http = Net::HTTP.new(host, port)
        http.use_ssl = ssl
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
