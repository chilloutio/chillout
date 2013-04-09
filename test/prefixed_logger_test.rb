require 'test_helper'

module Chillout
  class PrefixedLoggerTest < ChilloutTestCase
    def test_error_message_is_prefixed
      output = StringIO.new
      logger = Logger.new(output)
      prefixed_logger = PrefixedLogger.new("Chillout", logger)
      prefixed_logger.error "Someone is wrong on the internet"
      assert_includes output.string, "[Chillout] Someone is wrong on the internet"
    end

    def test_responds_to_flush
      logger = mock("logger")
      logger.expects(:flush)
      prefixed_logger = PrefixedLogger.new("Chillout", logger)
      prefixed_logger.flush
    end
  end
end
