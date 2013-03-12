require 'test_helper'
require 'chillout/creations_container'

module Chillout
  class CreationsContainerTest < ChilloutTestCase
    def setup
      @creations_container = CreationsContainer.new
    end

    def test_increment_model
      @creations_container.increment!("User")
      assert_equal 1, @creations_container[:User]
    end

    def test_merge
      @first_to_merge = CreationsContainer.new
      @first_to_merge.increment!("User", 2)
      @second_to_merge = CreationsContainer.new
      @second_to_merge.increment!("User")
      @second_to_merge.increment!("Entity")
      @creations_container.merge(@first_to_merge)
      @creations_container.merge(@second_to_merge)
      assert_equal 3, @creations_container[:User]
      assert_equal 1, @creations_container[:Entity]
    end
  end
end
