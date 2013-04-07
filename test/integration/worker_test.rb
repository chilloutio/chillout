require 'test_helper'
require 'chillout/creations_container'

class WorkerIntegrationTest < ChilloutTestCase

  def setup
    @_api_key = "xyz123"
    stub_request(:post, api_url('clients')).to_return(:body => "OK", :status => 200)
    stub_request(:post, api_url('metrics')).to_return(:body => "OK", :status => 200)
  end

  def test_worker_running_after_fork_on_first_use
    return if RUBY_PLATFORM == 'java'

    client = Chillout::Client.new(@_api_key, :logger => null_logger)
    worker_check = Proc.new do
      client.enqueue(Chillout::CreationsContainer.new)
      assert client.worker_running?
    end

    assert_successful_exit Process.fork(&worker_check)
  end

  def test_worker_running_lazily
    client = Chillout::Client.new(@_api_key, :logger => null_logger)
    client.enqueue(Chillout::CreationsContainer.new)

    assert client.worker_running?
  end

end
