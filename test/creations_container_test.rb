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

    def test_equality
      assert_equal CreationsContainer.new, CreationsContainer.new
      assert_equal(
        CreationsContainer.new.tap{|one| one.increment!("User") },
        CreationsContainer.new.tap{|one| one.increment!("User") },
      )
      assert_equal(
        CreationsContainer.new.tap{|one| one.increment!("User", 2) },
        CreationsContainer.new.tap{|one| one.increment!("User", 2) },
      )
      refute_equal(
        CreationsContainer.new.tap{|one| one.increment!("User", 3) },
        CreationsContainer.new.tap{|one| one.increment!("User", 2) },
      )
      refute_equal(
        CreationsContainer.new.tap{|one| one.increment!("User", 3) },
        CreationsContainer.new.tap{|one| one.increment!("Post", 3) },
      )
      refute_equal(
        Object.new,
        CreationsContainer.new.tap{|one| one.increment!("Post", 3) },
      )
      refute_equal(
        CreationsContainer.new.tap{|one| one.increment!("User", 3) },
        Object.new,
      )
    end

    def test_build_measurements_from_creations_container
      creations_container = CreationsContainer.new
      5.times { creations_container.increment!("User") }
      3.times { creations_container.increment!("Cart") }
      timestamp = Time.utc(2017, 6, 26, 15, 57, 10)

      assert_equal [{
          series: "User",
          tags: {},
          timestamp: "2017-06-26T15:57:10Z",
          values: { creations: 5 },
        },{
          series: "Cart",
          tags: {},
          timestamp: "2017-06-26T15:57:10Z",
          values: { creations: 3 },
        }], creations_container.as_measurements(timestamp)
    end
  end
end