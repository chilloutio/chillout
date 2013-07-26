module Chillout
  class ListenerInjector
    attr_accessor :logger

    LISTENERS = [:active_record, :mongoid]

    def inject!
      LISTENERS.each do |listener|
        listener_injection = send("#{listener}_injector") 
        logger.info "[Chillout] Injected #{listener} listener" if listener_injection == true
      end            
    end

    def active_record_injector
      if defined?(ActiveRecord)
        ActiveRecord::Base.extend(ActiveRecordCreationListener)
        return true
      end

      return false
    end

    def mongoid_injector
      if defined?(Mongoid)
        Mongoid::Document.extend(MongoidCreationListener)
        return true
      end

      return false
    end
  end
end
