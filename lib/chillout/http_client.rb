require 'net/http'
require 'net/https'
require 'json'

module Chillout
  class HttpClient
    class NotSent < StandardError
      attr_reader :original_exception
      def initialize(original_exception)
        @original_exception = original_exception
      end
    end

    class NotReceived < StandardError
      attr_reader :original_exception

      def initialize(original_exception)
        @original_exception = original_exception
      end
    end

    MEDIA_TYPE = "application/vnd.chillout.v1+json"

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def post(path, data)
      http = Net::HTTP.new(@config.hostname, @config.port)
      http.use_ssl = @config.ssl
      request_spec = Net::HTTP::Post.new(path)
      request_spec.body = JSON.dump(data)
      request_spec.content_type = MEDIA_TYPE
      request_spec.basic_auth @config.authentication_user, @config.authentication_password
      http.start do
        http.request(request_spec)
      end
    rescue => e
      @logger.error("#{e.class}: #{e.message}")
      raise NotSent.new(e)
    end

    def get(path)
      http = Net::HTTP.new(@config.hostname, @config.port)
      http.use_ssl = @config.ssl
      request_spec = Net::HTTP::Get.new(path)
      request_spec.content_type = MEDIA_TYPE
      request_spec.basic_auth @config.authentication_user, @config.authentication_password
      http.start do
        http.request(request_spec)
      end
    rescue => e
      raise NotReceived.new(e)
    end

  end
end
