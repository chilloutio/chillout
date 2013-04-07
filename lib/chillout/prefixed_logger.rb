module Chillout
  class PrefixedLogger
    attr_reader :prefix

    def initialize(prefix, logger)
      @prefix = prefix
      @logger = logger
    end

    [:error, :fatal, :warn, :info, :debug].each do |method_name|
      define_method method_name do |message|
        @logger.send(method_name, "[#{@prefix}] #{message}")
      end
    end
  end
end
