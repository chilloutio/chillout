require 'test_helper'

class DispatcherTest < ChilloutTestCase
  def test_send_creations
    server_side = mock("ServerSide")
    server_side.expects(:send_measurements).with(:creations)

    dispatcher = Chillout::Dispatcher.new(server_side)
    dispatcher.send_measurements(:creations)
  end

  def test_send_creations_raise_exception_if_server_side_failed_to_send_request
    server_side = stub()
    server_side.stubs(:send_measurements).raises(Chillout::HttpClient::NotSent.new(:http_error))

    dispatcher = Chillout::Dispatcher.new(server_side)

    assert_raises Chillout::Dispatcher::SendCreationsFailed do
      dispatcher.send_measurements(:creations)
    end
  end

end
