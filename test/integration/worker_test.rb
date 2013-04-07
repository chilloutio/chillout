require 'test_helper'
require 'chillout/creations_container'

class WorkerIntegrationTest < ChilloutTestCase

  def setup
    @_api_key = "xyz123"
    stub_request(:post, api_url('clients')).to_return(:body => "OK", :status => 200)
    stub_request(:post, api_url('metrics')).to_return(:body => "OK", :status => 200)
  end

  def silent_client
    Chillout::Client.new(@_api_key) do |config|
      config.logger = Logger.new('/dev/null')
    end
  end

  def test_worker_running_after_fork_on_first_use
    client = silent_client
    client.start_worker

    worker_check = Proc.new do
      client.enqueue(Chillout::CreationsContainer.new)
      assert client.worker_running?
    end
    assert_successful_exit Process.fork(&worker_check)
  end

  def assert_successful_exit(pid)
    _, status = Process.wait2(pid)
    assert_equal 0, status.exitstatus
  end

end
