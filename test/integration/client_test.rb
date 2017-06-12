require 'test_helper'

class ClientIntegrationTest < ChilloutTestCase
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
end
