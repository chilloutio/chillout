require 'chillout/creations_container'

module Chillout
  module CreationListener
    def inherited(subclass)
      super
      class_name = subclass.name
      subclass.after_commit :on => :create do
        Rails.logger.info "[Chillout] Model created: #{class_name}"
        Thread.current[:creations] ||= CreationsContainer.new
        creations = Thread.current[:creations]
        creations.increment!(class_name)
      end
    end
  end
end
