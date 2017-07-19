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

    def each(&proc)
      @container.each(&proc)
    end

    def resource_keys
      @container.keys
    end

    def merge(other_container)
      for key in other_container.resource_keys
        increment!(key, other_container[key])
      end
    end

    def ==(other)
      self.class == other.class &&
      @container == other.instance_variable_get(:@container)
    end

    def empty?
      @container.empty?
    end

    def size
      @container.size
    end

    def as_measurements(timestamp = Time.now)
      iso_timestamp = timestamp.iso8601
      @container.each.map do |model_name, value|
        {
          series: model_name.to_s,
          tags: {},
          timestamp: iso_timestamp,
          values: { creations: value },
        }
      end
    end

  end
end
