require 'test_helper'

module Chillout
  class WorkerTest < ChilloutTestCase
    def setup
      @dispatcher = stub
      @queue = stub
      @container = stub
      @logger = stub(info: "", error:"", debug: "")
      @container_class = stub(:new => @container)
      @worker = Worker.new(@dispatcher, @queue, @logger, @container_class)
    end

    def test_get_all_containers_to_process_pops_all_existings_jobs_from_queue
      @queue.expects(:pop).times(3).returns(:container1, :container2).then.raises(ThreadError)
      all_jobs = @worker.get_all_containers_to_process
      assert_equal 2, all_jobs.count
      assert_includes all_jobs, :container1
      assert_includes all_jobs, :container2
    end

    def test_merge_containers_to_one
      @container.expects(:merge).with(:container1)
      @container.expects(:merge).with(:container2)
      result = @worker.merge_containers([:container1, :container2])
      assert_equal @container, result
    end

    def test_send_creations_just_send_creations_with_dispatcher
      @dispatcher.expects(:send_creations).with(:creations_container)
      @worker.send_creations(:creations_container)
    end

    def test_send_creations_with_interuption
      @dispatcher.stubs(:send_creations).raises(Dispatcher::SendCreationsFailed)
      @queue.expects(:<<).with(:creations_container)
      @worker.send_creations(:creations_container)
    end

    def test_send_startup_message_is_delegated_to_dispatcher
      @dispatcher.expects(:send_startup_message)
      @worker.send_startup_message
    end
  end
end
