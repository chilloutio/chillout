require 'forwardable'
require 'chillout/server_side'
require 'chillout/http_client'
require 'chillout/error_filter'
require 'chillout/dispatcher'
require 'chillout/config'
require 'chillout/error'
require 'chillout/event_data_builder'
require 'chillout/prefixed_logger'
require 'chillout/worker'
require 'thread'

module Chillout
  class Client
    extend Forwardable

    def_delegators :@dispatcher, :dispatch_error, :send_error, :send_creations

    attr_reader :config
    attr_reader :logger
    attr_reader :queue

    def initialize(config_or_api_key, options = {})
      build_config(config_or_api_key, options)

      yield @config if block_given?

      @logger = PrefixedLogger.new("Chillout", @config.logger)

      @http_client = HttpClient.new(@config, logger)
      @event_data_builder = EventDataBuilder.new(@config)
      @server_side = ServerSide.new(@event_data_builder, @http_client)
      @filter = ErrorFilter.new
      @dispatcher = Dispatcher.new(@filter, @server_side)
      @queue = Queue.new
    end

    def send_exception(exception, environment = {})
      send_error(Error.new(exception, environment))
    end

    def enqueue(creations)
      @queue << creations
    end

    def start_worker
      thread = Thread.new do
        worker = Worker.new(@dispatcher, @queue, @logger)
        worker.run
      end
    end

    private
    def build_config(config_or_api_key, options)
      case config_or_api_key
      when Config
        @config = config_or_api_key
      when String
        @config = Config.new(config_or_api_key)
      else
        raise ArgumentError.new("Invalid config passed")
      end
      @config.update(options)
    end

  end
end
