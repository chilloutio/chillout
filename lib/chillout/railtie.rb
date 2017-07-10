require 'chillout/creation_listener'
require 'chillout/listener_injector'

module Chillout
  class Railtie < Rails::Railtie
    config.chillout = ActiveSupport::OrderedOptions.new
    chillout_init = nil

    initializer "chillout.creations_listener_initialization" do |rails_app|
      chillout_config = rails_app.config.chillout
      if chillout_config.present?
        chillout_init = RailsInitializer.new(rails_app, chillout_config, Rails.logger)
        chillout_init.start
      else
        Rails.logger.debug "[Chillout] Not enabled for #{Rails.env}"
      end
    end

    initializer "chillout.after_eager_load", after: :eager_load! do
      if chillout_init
        chillout_init.after_eager_load
      end
    end

    rake_tasks do
      load "chillout/tasks.rb"
    end

    generators do
      require "chillout/generators/install"
    end
  end

  class RailsInitializer

    def initialize(rails_app, chillout_config, rails_logger)
      @rails_app = rails_app
      @chillout_config = chillout_config
      @rails_logger = rails_logger
    end

    def start(listeners_injector = ListenerInjector.new)
      listeners_injector.logger = @rails_logger

      @rails_logger.info "[Chillout] Railtie initializing"
      config = build_config(options)
      client = Client.new(config)
      if config.creations_tracking
        listeners_injector.inject!
        @rails_logger.info "[Chillout] Creation monitor enabled"
      end
      @rails_app.middleware.use Middleware::CreationsMonitor, client

      sidekiq = Integrations::Sidekiq.new
      sidekiq.enable(client) if sidekiq.available?

      if config.requests_tracking
        @rails_logger.info "[Chillout] Requests monitor enabled"
        Subscribers::ActionControllerNotifications.new.enable(client)
      end
      client.start
      Chillout.client = client
    end

    def after_eager_load
      state_machine = Integrations::StateMachine.new
      state_machine.enable(Chillout.client) if state_machine.available?
    end

    private

    def options
      {logger: @rails_logger}.merge(@chillout_config)
    end

    def build_config(options)
      config = Config.new
      config.update(options)
      config
    end

  end
end
