module Chillout
  class EventDataBuilder
    def initialize(config)
      @config = config
    end

    def build_from_creations_container(creations_container, timestamp)
      {
        :metric => "creations",
        :timestamp => timestamp,
        :content => {
          :creations => build_creations_content(creations_container),
          :environment => @config.environment
        },
        :notifier => build_notifier
      }
    end

    def build_creations_content(creations_container)
      creation_tuples = creations_container.resource_keys.map do |key|
        [key, creations_container[key]]
      end
      Hash[creation_tuples]
    end

    def build_notifier
      {
        :name => @config.notifier_name,
        :version => @config.version,
        :url => @config.notifier_url
      }
    end
  end
end
