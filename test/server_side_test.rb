require 'test_helper'
require 'time'

class ServerSideTest < ChilloutTestCase

  def setup
    @event_data_builder = mock("EventDataBuilder")
    @http_client = mock("HttpClient")
    @server_side = Chillout::ServerSide.new(@event_data_builder, @http_client)
  end

  def test_send_error_use_event_data_builder
    @event_data_builder.expects(:build_from_error).with(:error, anything).returns(:event_data_from_builder)
    @http_client.stubs(:post)
    @server_side.send_error(:error)
  end

  def test_send_error_use_http_client
    @event_data_builder.stubs(:build_from_error).returns(:event_data_from_builder)
    @http_client.expects(:post).with('/events', :event_data_from_builder)
    @server_side.send_error(:error)
  end

  def test_send_creations_use_event_data_builder
    @event_data_builder.expects(:build_from_creations_container).with(:creations_container, anything).returns(:event_data_from_builder)
    @http_client.stubs(:post)
    @server_side.send_creations(:creations_container)
  end

  def test_send_creations_use_http_client
    @event_data_builder.stubs(:build_from_creations_container).returns(:event_data_from_builder)
    @http_client.expects(:post).with('/metrics', :event_data_from_builder)
    @server_side.send_creations(:creations_container)
  end
end
