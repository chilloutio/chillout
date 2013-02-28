module Chillout
  class CreationsContainer
    def initialize
      @container = Hash.new {|hash, key| hash[key] = 0}
    end

    def increment!(class_name)
      key = class_name.to_sym
      @container[key] += 1
    end

    def [](name)
      key = name.to_sym
      @container[key]
    end

    def resource_keys
      @container.keys
    end
  end
end
