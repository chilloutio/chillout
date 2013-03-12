module Chillout
  class CreationsContainer
    def initialize
      @container = Hash.new {|hash, key| hash[key] = 0}
    end

    def increment!(class_name, value=1)
      key = key(class_name)
      @container[key] += value
    end

    def [](name)
      key = key(name)
      @container[key]
    end

    def key(name)
      name.to_sym
    end

    def resource_keys
      @container.keys
    end

    def merge(other_container)
      for key in other_container.resource_keys
        increment!(key, other_container[key])
      end
    end
  end
end
