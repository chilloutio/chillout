require 'chillout/creation_listener'

module Chillout
  class Railtie < Rails::Railtie
    config.chillout = ActiveSupport::OrderedOptions.new
    initializer "chillout.creations_listener_initialization" do |rails_app|
      chillout_config = rails_app.config.chillout
      if !chillout_config.empty?
        RailsInitializer.new(rails_app, chillout_config, Rails.logger).start
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

    def start
      @rails_logger.info "[Chillout] Railtie initializing"
      client = Client.new(@chillout_config[:secret], options)
      ActiveRecord::Base.extend(CreationListener)
      @rails_logger.info "[Chillout] Creation listener attached"
      @rails_app.middleware.use Middleware::CreationsMonitor, client
      @rails_logger.info "[Chillout] Creation monitor enabled"
    end

    def options
      Hash[options_list].merge(:logger => @rails_logger)
    end

    def options_list
      existing_option_keys.map{|key| [key, @chillout_config[key]]}
    end

    def existing_option_keys
      [:port, :hostname, :ssl].select{|key| @chillout_config.has_key?(key)}
    end

  end
end
