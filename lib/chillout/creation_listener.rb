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
      monitored_class.after_commit :on => :create do
        Rails.logger.info "[Chillout] Model created: #{class_name}"
        Thread.current[:creations] ||= CreationsContainer.new
        creations = Thread.current[:creations]
        creations.increment!(class_name)
      end
    end
  end

  module MongoidCreationListener
    def included(included_into)
      super
      listen(included_into)
    end
    
    def listen(monitored_class)
      class_name = monitored_class.name
      monitored_class.after_create :on => :create do
        Rails.logger.info "[Chillout] Model created: #{class_name}"
        Thread.current[:creations] ||= CreationsContainer.new
        creations = Thread.current[:creations]
        creations.increment!(class_name)
      end
    end
  end
end
