require 'chillout/creations_container'

module Chillout
  module ActiveRecordCreationListener
    def inherited(subclass)
      super
      listen(subclass)
    end

    private
    def listen(monitored_class)
      class_name = monitored_class.name
      return unless class_name
      monitored_class.after_commit :on => :create do
        Rails.logger.debug "[Chillout] Model created: #{class_name}"
        Chillout.creations ||= CreationsContainer.new
        Chillout.creations.increment!(class_name)
      end
    end
  end
end