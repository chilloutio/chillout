require 'test_helper'

module Chillout
  class WorkerTest < ChilloutTestCase
    def setup
      @dispatcher = stub
      @queue = stub
      @container = stub
      @logger = stub(info: "", error:"", debug: "")
      @container_class = stub(:new => @container)
      @max_queue = 50
      @worker = Worker.new(@max_queue, @dispatcher, @queue, @logger, @container_class)
    end

    def test_get_all_containers_to_process_pops_all_existings_jobs_from_queue
      @queue.expects(:pop).times(3).returns(:container1, :container2).then.raises(ThreadError)
      assert_equal [:container1, :container2], @worker.get_all_containers_to_process
    end

    def test_does_not_pop_containers_infinitely
      @queue.expects(:pop).returns(:bip).times(@max_queue)
      assert_equal [:bip]*@max_queue, @worker.get_all_containers_to_process
    end

    def test_merge_heterogeneous_containers
      @worker = Worker.new(@max_queue, @dispatcher, @queue, @logger, CreationsContainer)

      result = @worker.merge_containers([
        CreationsContainer.new.tap{|cc| cc.increment!("User", 2); },
        nil,
        other = Object.new,
        CreationsContainer.new.tap{|cc| cc.increment!("User", 3); },
        1,
      ])
      assert_equal [
        CreationsContainer.new.tap{|cc| cc.increment!("User", 5); },
        nil,
        other,
        1
      ], result
    end

    def test_merge_homogeneous_containers
      @worker = Worker.new(@max_queue, @dispatcher, @queue, @logger, CreationsContainer)

      result = @worker.merge_containers([
        CreationsContainer.new.tap{|cc| cc.increment!("User", 2); },
        CreationsContainer.new.tap{|cc| cc.increment!("User", 3); },
      ])
      assert_equal [
        CreationsContainer.new.tap{|cc| cc.increment!("User", 5); },
      ], result
    end

    def test_send_measurements_just_send_creations_with_dispatcher
      @dispatcher.expects(:send_measurements).with(:creations_container)
      @worker.send_measurements(:creations_container)
    end

    def test_send_measurements_with_interuption
      @dispatcher.stubs(:send_measurements).raises(Dispatcher::SendCreationsFailed)
      @worker.send_measurements(:creations_container)
    end

    def test_send_startup_message_is_delegated_to_dispatcher
      @dispatcher.expects(:send_startup_message)
      @worker.send_startup_message
    end
  end
end