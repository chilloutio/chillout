class Chillout::Job < ActiveJob::Base
  queue_as :chillout

  class << self
    attr_accessor :dispatcher
  end

  def perform(serialized_metrics)
    metrics = YAML.load(serialized_metrics)
    self.class.dispatcher.send_creations(metrics)
  end
end