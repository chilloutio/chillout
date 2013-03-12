require 'chillout/creation_listener'

module Chillout
  class Railtie < Rails::Railtie
    config.chillout = ActiveSupport::OrderedOptions.new
    initializer "chillout.exceptions_listener_initialization" do |app|
      if !app.config.chillout.empty?
        existing_option_keys = [:port, :hostname, :ssl].select{|key| app.config.chillout.has_key?(key)}
        options_list = existing_option_keys.map{|key| [key, app.config.chillout[key]]}
        options = Hash[options_list].merge(logger: Rails.logger)

        client = Client.new(app.config.chillout[:secret], options)

        ActiveRecord::Base.extend(CreationListener)

        app.middleware.use Middleware::ExceptionMonitor, client
        app.middleware.use Middleware::CreationsMonitor, client

        client.start_worker
      end
    end
  end
end
