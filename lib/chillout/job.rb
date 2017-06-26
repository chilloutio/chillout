class Chillout::Job < ActiveJob::Base
  queue_as :chillout

  class << self
    attr_accessor :dispatcher
  end

  def perform(serialized_metric)
    measurement = YAML.load(serialized_metric)
    self.class.dispatcher.send_measurements([measurement])
  end
end