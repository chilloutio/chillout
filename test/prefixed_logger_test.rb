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
  end
end