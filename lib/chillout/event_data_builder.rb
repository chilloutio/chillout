module Chillout
  class EventDataBuilder
    def initialize(config)
      @config = config
    end

    def build_from_error(error, timestamp)
      {
        event: "exception",
        timestamp: timestamp,
        content: {
          class: error.exception_class,
          message: error.message,
          backtrace: error.backtrace,
          file: error.file,
          environment: @config.environment,
          context: {
            platform: @config.platform,
            controller: error.controller_name,
            action: error.controller_action,
            current_user: {
              id: error.current_user_id,
              email: error.current_user_email,
              full_name: error.current_user_full_name
            }
          },
          rack_environment: build_rack_environment(error),
          shell_environment: @config.shell_environment
        },
        notifier: build_notifier
      }
    end

    def build_from_creations_container(creations_container, timestamp)
      {
        metric: "creations",
        timestamp: timestamp,
        content: {
          creations: build_creations_content(creations_container),
          environment: @config.environment
        },
        notifier: build_notifier
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
        name: @config.notifier_name,
        version: @config.version,
        url: @config.notifier_url
      }
    end

    def build_rack_environment(error)
      Hash[error.environment.collect do |key, value|
        [key, value.to_s]
      end]
    end
  end
end
