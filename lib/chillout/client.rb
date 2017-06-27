require 'forwardable'
require 'chillout/server_side/server_side'
require 'chillout/server_side/http_client'
require 'chillout/server_side/dispatcher'
require 'chillout/config'
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
      @server_side = ServerSide.new(@config, @http_client).freeze
      @dispatcher = Dispatcher.new(@server_side).freeze
      case @config.strategy
      when :thread
        @queue = Queue.new
        @worker_mutex = Mutex.new
        @worker_thread = nil
        @max_queue = config.max_queue
      when :active_job
        require 'chillout/job'
        Chillout::Job.dispatcher = @dispatcher
      end
    end

    def start
      case @config.strategy
      when :thread
        start_worker
      when :active_job
      end
    end

    def enqueue(metrics)
      case @config.strategy
      when :thread
        start_worker
        if @queue.size < @max_queue
          @queue << metrics
          @logger.debug "Metrics were enqueued."
        else
          @logger.error "Metrics buffer overflow. Skipping enqueue."
        end
      when :active_job
        Chillout::Job.perform_later(YAML.dump(metrics))
        @logger.debug "Metrics were enqueued."
      end
    end

    def worker_running?
      @worker_thread && @worker_thread.alive?
    end

    def start_worker
      return if worker_running?
      @worker_mutex.synchronize do
        return if worker_running?
        @worker_thread = Thread.new do
          worker = Worker.new(@dispatcher, @queue, @logger)
          worker.run
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
