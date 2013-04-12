require 'forwardable'
require 'chillout/server_side/server_side'
require 'chillout/server_side/http_client'
require 'chillout/server_side/dispatcher'
require 'chillout/config'
require 'chillout/event_data_builder'
require 'chillout/prefixed_logger'
require 'chillout/worker'
require 'chillout/check_result'
require 'thread'

module Chillout
  class Client
    extend Forwardable

    def_delegators :@dispatcher, :send_creations, :check_api_connection

    attr_reader :config
    attr_reader :logger
    attr_reader :queue

    def initialize(config_or_api_key, options = {})
      build_config(config_or_api_key, options)

      yield @config if block_given?

      @logger = PrefixedLogger.new("Chillout", @config.logger)

      @http_client = HttpClient.new(@config, logger).freeze
      @event_data_builder = EventDataBuilder.new(@config).freeze
      @server_side = ServerSide.new(@event_data_builder, @http_client).freeze
      @dispatcher = Dispatcher.new(@server_side).freeze
      @queue = Queue.new
      @worker_mutex = Mutex.new
    end

    def enqueue(creations)
      start_worker
      @logger.info "Creations were enqueued."
      @queue << creations
    end

    def worker_running?
      @worker_thread && @worker_thread.alive?
    end

    def start_worker
      return if worker_running?
      @worker_mutex.synchronize do
        return if worker_running?
        @worker_thread = Thread.new do
          begin
            worker = Worker.new(@dispatcher, @queue, @logger)
            worker.run
          ensure
            @logger.flush
          end
        end
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
