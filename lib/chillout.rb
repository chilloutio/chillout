require "chillout/version"
require "chillout/config"
require "chillout/creations_container"
require "chillout/custom_advanced_metric"
require "chillout/middleware/creations_monitor"
require "chillout/integrations/sidekiq"
require "chillout/integrations/state_machine"
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

    def self.push(series:, tags:{}, timestamp: Time.now.utc, values: {value: 1.0})
      Chillout.client.enqueue(CustomAdvancedMetric.new(
        series: series,
        tags: tags,
        timestamp: timestamp,
        values: values
      ))
    end
  end

  def self.creations
    Thread.current[:creations]
  end

  def self.creations=(val)
    Thread.current[:creations] = val
  end

  def self.client=(client)
    @client = client
  end

  def self.client
    @client
  end
end

require 'chillout/railtie' if defined?(Rails)