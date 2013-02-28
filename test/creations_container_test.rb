require 'test_helper'
require 'chillout/creations_container'

module Chillout
  class CreationsContainerTest < ChilloutTestCase
    def test_increment_model
      creations_container = CreationsContainer.new
      creations_container.increment!("User")
      assert_equal 1, creations_container[:User]
    end
  end
end
