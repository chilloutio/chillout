module Chillout
  class Worker
    attr_reader :dispatcher, :queue, :logger

    def initialize(dispatcher, queue, logger)
      @dispatcher = dispatcher
      @queue = queue
      @logger = logger
    end

    def run
      loop do
        containers_to_merge = [queue.pop]
        loop do
          begin
            containers_to_merge << queue.pop(true)
          rescue ThreadError
            break
          end
        end
        creations_container = CreationsContainer.new
        for container in containers_to_merge
          creations_container.merge(container)
        end
        dispatcher.send_creations(creations_container)
        logger.info "Sending metrics"
        sleep 5
      end
    end
  end
end
