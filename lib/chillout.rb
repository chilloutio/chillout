require "chillout/version"
require "chillout/config"
require "chillout/creations_container"
require "chillout/middleware/creations_monitor"
require "chillout/integrations/sidekiq"
require "chillout/subscribers/action_controller_notifications"
require "chillout/server_side/dispatcher"
require "chillout/server_side/server_side"
require "chillout/server_side/http_client"
require "chillout/client"

module Chillout
  module Metric
    def self.track(name)
      Chillout.creations ||= CreationsContainer.new
      Chillout.creations.increment!(name)
    end
  end

  def self.creations
    Thread.current[:creations]
  end

  def self.creations=(val)
    Thread.current[:creations] = val
  end
end

require 'chillout/railtie' if defined?(Rails)