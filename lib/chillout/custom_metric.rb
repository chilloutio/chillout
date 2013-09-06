require 'chillout/creations_container'

module Chillout
  class CustomMetric
    def initialize(creations_container = nil)
      @creations_container = creations_container
    end

    def track(name)
      creations_container.increment!(name)
    end
   
    private
    def creations_container
      if container_not_initialized?
        Thread.current[:creations] ||= CreationsContainer.new
        @creations_container = Thread.current[:creations]
      else
        @creations_container
      end
    end

    def container_not_initialized?
      @creations_container.nil?
    end
  end
end
