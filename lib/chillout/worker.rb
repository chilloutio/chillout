module Chillout
  class Worker
    attr_reader :dispatcher, :queue, :logger

    def initialize(dispatcher, queue, logger, container_class=CreationsContainer)
      @dispatcher = dispatcher
      @queue = queue
      @logger = logger
      @container_class = container_class
    end

    def get_all_containers_to_process
      logger.debug "Waiting for at least one container."
      all_containers = [queue.pop]
      logger.debug "Received at least one container."
      loop do
        begin
          all_containers << queue.pop(true)
        rescue ThreadError
          break
        end
      end
      logger.debug "Received containers to process: #{all_containers.count}"
      all_containers
    end

    def merge_containers(containers_to_merge)
      mergable, unmergable = containers_to_merge.partition{|cont| @container_class === cont }
      creations_container = @container_class.new
      mergable.each do |container|
        creations_container.merge(container)
      end
      unmergable.unshift(creations_container) unless creations_container.empty?
      unmergable
    end

    def send_measurements(measurements)
      logger.debug "Trying to send creations"
      dispatcher.send_measurements(measurements)
      logger.info "Metrics sent"
    rescue Dispatcher::SendCreationsFailed
      logger.error "Sending metrics failed"
    end

    def send_startup_message
      dispatcher.send_startup_message
      logger.debug "Sending startup message"
    end

    def run
      logger.info "Worker started"
      send_startup_message
      loop do
        containers_to_merge = get_all_containers_to_process
        measurements = merge_containers(containers_to_merge)
        send_measurements(measurements)
        sleep 5
      end
    end
  end
end