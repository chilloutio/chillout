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
      all_containers = [queue.pop]
      loop do
        begin
          all_containers << queue.pop(true)
        rescue ThreadError
          break
        end
      end
      all_containers
    end

    def merge_containers(containers_to_merge)
      creations_container = @container_class.new
      for container in containers_to_merge
        creations_container.merge(container)
      end
      creations_container
    end

    def send_creations(creations_container)
      dispatcher.send_creations(creations_container)
      logger.info "Sending metrics"
    rescue Dispatcher::SendCreationsFailed
      queue << creations_container
      logger.error "Sending metrics failed"
    end

    def run
      loop do
        containers_to_merge = get_all_containers_to_process
        creations_container = merge_containers(containers_to_merge)
        send_creations(creations_container)
        sleep 5
      end
    end
  end
end