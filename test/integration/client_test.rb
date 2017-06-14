require 'test_helper'
require 'active_job'
require 'active_job/test_helper'

class ClientIntegrationTest < ChilloutTestCase
  include ActiveJob::TestHelper

  def test_check_api_connection_with_200_ok_response
    @_api_key = "xyz123"
    url = api_url("check")
    stub_request(:get, url).with(basic_auth: ['xyz123', 'xyz123']).
      to_return(:body => "OK", :status => 200)

    client = Chillout::Client.new(@_api_key)
    check_result = client.check_api_connection
    assert check_result.successful?, "Check was not successful"
  end

  def test_check_api_connection_with_other_response
    @_api_key = "xyz123"
    url = api_url("check")
    stub_request(:get, url).with(basic_auth: ['xyz123', 'xyz123']).
      to_return(:body => "Not Found", :status => 404)

    client = Chillout::Client.new(@_api_key)
    check_result = client.check_api_connection
    refute check_result.successful?, "Check was successful"
  end

  def test_check_api_connection_with_raised_exception_on_request
    @_api_key = "xyz123"
    url = api_url("check")
    stub_request(:get, url).with(basic_auth: ['xyz123', 'xyz123']).
      to_raise(StandardError)

    client = Chillout::Client.new(@_api_key)
    check_result = client.check_api_connection
    refute check_result.successful?, "Check was successful"
  end

  def test_client_creats_new_worker_thread_after_exception
    @_api_key = "xyz123"
    stub_request(:post, api_url("clients")).with(basic_auth: ['xyz123', 'xyz123']).
      to_return(:body => "OK", :status => 200)
    stub_request(:post, api_url("metrics")).with(basic_auth: ['xyz123', 'xyz123']).
      to_return(:body => "OK", :status => 200)

    client = Chillout::Client.new(@_api_key)
    client.enqueue(Chillout::CreationsContainer.new)
    assert client.worker_running?

    client.enqueue(nil)
    sleep(6)
    refute client.worker_running?

    client.enqueue(Chillout::CreationsContainer.new)
    assert client.worker_running?

    client.enqueue(nil)
    sleep(6)
    refute client.worker_running?
  end

  def test_active_job_queueing
    assert_enqueued_jobs 0
    client = Chillout::Client.new("xyz123", strategy: :active_job)
    container = Chillout::CreationsContainer.new
    container.increment!("User")

    assert_enqueued_jobs 1, only: Chillout::Job, queue: "chillout" do
      client.enqueue(container)
    end
  end

  def test_active_job_performing
    @_api_key = "xyz123"
    stub_request(:post, api_url("metrics")).with(basic_auth: ['xyz123', 'xyz123']).
      to_return(:body => "OK", :status => 200)

    client = Chillout::Client.new("xyz123", strategy: :active_job)
    container = Chillout::CreationsContainer.new
    container.increment!("User")

    perform_enqueued_jobs do
      assert_performed_jobs 1, only: Chillout::Job do
        client.enqueue(container)
      end
    end
  end

  private

  def self.active_job_4_test_helper?
    instance_method(:assert_performed_jobs).arity == 1 && instance_method(:assert_enqueued_jobs).arity == 1
  end

  if active_job_4_test_helper?
    prepend(Module.new(){
      def assert_performed_jobs(number, only: nil, &block)
        super(number, &block)
      end
      def assert_enqueued_jobs(number, only: nil, queue: nil, &block)
        super(number, &block)
      end
    })
  end
end